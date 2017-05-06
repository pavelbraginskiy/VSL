import Transformation from '../transformation.js';
import TransformError from '../transformError.js';
import AccessModifiers from '../data/accessModifiers';
import t from '../../parser/nodes';

/**
 * Verifies and determines if a functions access modifiers are valid within its
 * scope.
 * 
 * An example is if a function declared `static func` is outside of a function.
 * This does not implement access modifers either but just checks a function's
 * scope
 */
export default class VerifyFunctionAccessScope extends Transformation {
    constructor() {
        super(t.FunctionStatement, "Verify::FunctionAccessScope");
    }
    
    /** @overide */
    modify(node: Node, tool: ASTTool) {
        // Statement[] -> CodeBlock -> ClassStatement
        let classStatement = tool.nthParent(3);
        let accessModifiers = node.access;
        
        if (classStatement instanceof t.ClassStatement) {
            // A class function
            
            return;
        }
        
        if (classStatement === null) {
            // Top-level function
            
            return;
        }
        
        // Nested function
        if (accessModifiers.length > 0) {
            throw new TransformError("Functions inside scopes may not have any modifiers.", node);
        }
    }
}