#!/usr/bin/env python3
"""
Design System Code Generator
Generates Swift and Kotlin state machine code from YAML specification
"""

import yaml
import os
from pathlib import Path
from typing import Dict, List, Any


class StateCodeGenerator:
    def __init__(self, spec_path: str):
        with open(spec_path, 'r') as f:
            self.spec = yaml.safe_load(f)
    
    def generate_swift_state_machine(self) -> str:
        """Generate Swift state machine code"""
        states = self.spec['state_machine']['states']
        transitions = self.spec['state_machine']['transitions']
        
        code = '''//
// EntityState.swift
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

import Foundation

/// Universal state machine for all UI entities
public enum EntityState: String, CaseIterable {
'''
        
        # Generate enum cases
        for state in states:
            code += f'    case {state}\n'
        
        code += '''}

// MARK: - State Transitions

public extension EntityState {
    /// Check if transition to target state is valid
    func canTransition(to targetState: EntityState) -> Bool {
        switch self {
'''
        
        # Generate transition logic
        for transition in transitions:
            from_state = transition['from']
            to_states = transition['to']
            code += f'        case .{from_state}:\n'
            code += f'            return ['
            code += ', '.join([f'.{s}' for s in to_states])
            code += '].contains(targetState)\n'
        
        code += '''        }
    }
    
    /// Transition to new state if valid
    func transition(to targetState: EntityState) -> EntityState? {
        return canTransition(to: targetState) ? targetState : nil
    }
}

// MARK: - State Properties

public extension EntityState {
    /// Whether this state is interactive
    var isInteractive: Bool {
        switch self {
        case .idle, .focus, .pressed, .active:
            return true
        case .rewarded, .error, .disabled:
            return false
        }
    }
    
    /// Whether this state requires animation
    var requiresAnimation: Bool {
        return self != .disabled
    }
}
'''
        return code
    
    def generate_kotlin_state_machine(self) -> str:
        """Generate Kotlin state machine code"""
        states = self.spec['state_machine']['states']
        transitions = self.spec['state_machine']['transitions']
        
        code = '''//
// EntityState.kt
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

package com.designsystem.core

/**
 * Universal state machine for all UI entities
 */
sealed class EntityState(val stateName: String) {
'''
        
        # Generate sealed class hierarchy
        for state in states:
            state_name = ''.join(word.capitalize() for word in state.split('_'))
            code += f'    object {state_name} : EntityState("{state}")\n'
        
        code += '''}

// State Transitions

/**
 * Check if transition to target state is valid
 */
fun EntityState.canTransitionTo(targetState: EntityState): Boolean {
    return when (this) {
'''
        
        # Generate transition logic
        for transition in transitions:
            from_state = transition['from']
            to_states = transition['to']
            from_class = ''.join(word.capitalize() for word in from_state.split('_'))
            to_classes = [f'EntityState.{"".join(word.capitalize() for word in s.split("_"))}' for s in to_states]
            
            code += f'        is EntityState.{from_class} -> targetState in listOf({", ".join(to_classes)})\n'
        
        code += '''    }
}

/**
 * Transition to new state if valid
 */
fun EntityState.transitionTo(targetState: EntityState): EntityState? {
    return if (canTransitionTo(targetState)) targetState else null
}

// State Properties

/**
 * Whether this state is interactive
 */
val EntityState.isInteractive: Boolean
    get() = when (this) {
        is EntityState.Idle,
        is EntityState.Focus,
        is EntityState.Pressed,
        is EntityState.Active -> true
        else -> false
    }

/**
 * Whether this state requires animation
 */
val EntityState.requiresAnimation: Boolean
    get() = this !is EntityState.Disabled

/**
 * All possible states
 */
fun getAllStates(): List<EntityState> = listOf(
'''
        
        # List all states
        state_list = []
        for state in states:
            state_name = ''.join(word.capitalize() for word in state.split('_'))
            state_list.append(f'    EntityState.{state_name}')
        code += ',\n'.join(state_list)
        
        code += '\n)\n'
        return code
    
    def generate_swift_entities(self) -> Dict[str, str]:
        """Generate Swift entity configuration classes"""
        entities = {}
        
        for entity_name, entity_data in self.spec['entities'].items():
            class_name = ''.join(word.capitalize() for word in entity_name.split('_'))
            
            code = f'''//
// {class_name}Config.swift
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

import Foundation
import CoreGraphics

/// Configuration for {class_name} entity
public struct {class_name}Config {{
    public let type: EntityType = .{entity_data['type']}
    
'''
            
            # Generate state configurations
            code += '    /// Visual configuration for each state\n'
            code += '    public struct StateVisual {\n'
            code += '        public let scale: CGFloat\n'
            code += '        public let glow: CGFloat\n'
            code += '        public let opacity: CGFloat\n'
            code += '        public let elevation: Int?\n'
            code += '        public let color: String?\n'
            code += '        public let particles: Bool\n'
            code += '        public let shake: Bool\n'
            code += '        public let pulse: Bool\n'
            code += '        public let blurBackground: Bool\n'
            code += '    }\n\n'
            
            code += '    public let stateVisuals: [EntityState: StateVisual]\n\n'
            code += '    public init() {\n'
            code += '        var visuals: [EntityState: StateVisual] = [:]\n\n'
            
            for state_name, state_config in entity_data.get('states', {}).items():
                visual = state_config.get('visual', {})
                code += f'        // {state_name} state\n'
                code += f'        visuals[.{state_name}] = StateVisual(\n'
                code += f'            scale: {visual.get("scale", 1.0)},\n'
                code += f'            glow: {visual.get("glow", 0.0)},\n'
                code += f'            opacity: {visual.get("opacity", 1.0)},\n'
                
                elevation = visual.get('elevation')
                if elevation:
                    # Extract number from string like "z2"
                    elev_num = elevation.replace('z', '') if isinstance(elevation, str) else elevation
                    code += f'            elevation: {elev_num},\n'
                else:
                    code += f'            elevation: nil,\n'
                
                color = visual.get('color')
                color_str = f'"{color}"' if color else "nil"
                code += f'            color: {color_str},\n'
                code += f'            particles: {str(visual.get("particles", False)).lower()},\n'
                code += f'            shake: {str(visual.get("shake", False)).lower()},\n'
                code += f'            pulse: {str(visual.get("pulse", False)).lower()},\n'
                code += f'            blurBackground: {str(visual.get("blur_background", False)).lower()}\n'
                code += f'        )\n\n'
            
            code += '        self.stateVisuals = visuals\n'
            code += '    }\n'
            code += '}\n\n'
            
            code += 'public enum EntityType {\n'
            code += '    case interactive\n'
            code += '    case container\n'
            code += '    case indicator\n'
            code += '    case navigation\n'
            code += '}\n'
            
            entities[entity_name] = code
        
        return entities
    
    def generate_kotlin_entities(self) -> Dict[str, str]:
        """Generate Kotlin entity configuration classes"""
        entities = {}
        
        for entity_name, entity_data in self.spec['entities'].items():
            class_name = ''.join(word.capitalize() for word in entity_name.split('_'))
            
            code = f'''//
// {class_name}Config.kt
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

package com.designsystem.entities

import com.designsystem.core.EntityState

/**
 * Configuration for {class_name} entity
 */
class {class_name}Config {{
    val type: EntityType = EntityType.{entity_data['type'].upper()}
    
    /**
     * Visual configuration for a state
     */
    data class StateVisual(
        val scale: Float = 1.0f,
        val glow: Float = 0.0f,
        val opacity: Float = 1.0f,
        val elevation: Int? = null,
        val color: String? = null,
        val particles: Boolean = false,
        val shake: Boolean = false,
        val pulse: Boolean = false,
        val blurBackground: Boolean = false
    )
    
    val stateVisuals: Map<EntityState, StateVisual> = mapOf(
'''
            
            for state_name, state_config in entity_data.get('states', {}).items():
                visual = state_config.get('visual', {})
                state_class = ''.join(word.capitalize() for word in state_name.split('_'))
                
                code += f'        EntityState.{state_class} to StateVisual(\n'
                code += f'            scale = {visual.get("scale", 1.0)}f,\n'
                code += f'            glow = {visual.get("glow", 0.0)}f,\n'
                code += f'            opacity = {visual.get("opacity", 1.0)}f,\n'
                
                elevation = visual.get('elevation')
                if elevation:
                    elev_num = elevation.replace('z', '') if isinstance(elevation, str) else elevation
                    code += f'            elevation = {elev_num},\n'
                else:
                    code += f'            elevation = null,\n'
                
                color = visual.get('color')
                color_str = f'"{color}"' if color else "null"
                code += f'            color = {color_str},\n'
                code += f'            particles = {str(visual.get("particles", False)).lower()},\n'
                code += f'            shake = {str(visual.get("shake", False)).lower()},\n'
                code += f'            pulse = {str(visual.get("pulse", False)).lower()},\n'
                code += f'            blurBackground = {str(visual.get("blur_background", False)).lower()}\n'
                code += f'        ),\n'
            
            code += '    )\n'
            code += '}\n\n'
            
            code += 'enum class EntityType {\n'
            code += '    INTERACTIVE,\n'
            code += '    CONTAINER,\n'
            code += '    INDICATOR,\n'
            code += '    NAVIGATION\n'
            code += '}\n'
            
            entities[entity_name] = code
        
        return entities
    
    def generate_all(self, output_dir: Path):
        """Generate all code files"""
        ios_dir = output_dir / 'ios' / 'generated'
        android_dir = output_dir / 'android' / 'generated'
        
        ios_dir.mkdir(parents=True, exist_ok=True)
        android_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate Swift files
        print("Generating Swift code...")
        swift_state = self.generate_swift_state_machine()
        (ios_dir / 'EntityState.swift').write_text(swift_state)
        
        swift_entities = self.generate_swift_entities()
        for entity_name, code in swift_entities.items():
            class_name = ''.join(word.capitalize() for word in entity_name.split('_'))
            (ios_dir / f'{class_name}Config.swift').write_text(code)
        
        # Generate Kotlin files
        print("Generating Kotlin code...")
        kotlin_state = self.generate_kotlin_state_machine()
        (android_dir / 'EntityState.kt').write_text(kotlin_state)
        
        kotlin_entities = self.generate_kotlin_entities()
        for entity_name, code in kotlin_entities.items():
            class_name = ''.join(word.capitalize() for word in entity_name.split('_'))
            (android_dir / f'{class_name}Config.kt').write_text(code)
        
        print(f"✅ Generated {len(swift_entities) + 1} Swift files")
        print(f"✅ Generated {len(kotlin_entities) + 1} Kotlin files")


def main():
    import sys
    
    script_dir = Path(__file__).parent
    spec_path = script_dir.parent / 'spec' / 'design.yaml'
    output_dir = script_dir.parent
    
    if not spec_path.exists():
        print(f"Error: Specification file not found at {spec_path}")
        sys.exit(1)
    
    generator = StateCodeGenerator(str(spec_path))
    generator.generate_all(output_dir)
    print("\n✅ Code generation complete!")


if __name__ == '__main__':
    main()
