module Presentation
import IO;
import vis::Text; //prettyTree

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import Resolve;

public void runPresentation_Syntax(){
    str fileContent = readFile(|cwd:///examples/present/syntax.myql|);
    Tree t = parse(#start[Form], fileContent);
    println("Tree: ");
    println(t);
    println("Pretty Tree: ");
    println(prettyTree(t));

}

public void runPresentation_AST(){
    str fileContent = readFile(|cwd:///examples/present/syntax.myql|);
    Tree t = parse(#start[Form], fileContent);
    AForm f = cst2ast(t);

    println("AForm: ");
    println(f);    
}

public void runPresentation_Resolve(){
    str fileContent = readFile(|cwd:///examples/present/syntax.myql|);
    Tree t = parse(#start[Form], fileContent);
    AForm f = cst2ast(t);
    
    RefGraph rg = resolve(f);

    println("RefGraph.uses: ");
    println(rg.uses);

    println("\n RefGraph.defs: ");
    println(rg.defs);

    println("\n RefGraph.useDef: ");
    println(rg.useDef);

}

public void runPresentation_Check(){
    str fileContent = readFile(|cwd:///examples/present/syntax.myql|);
    Tree t = parse(#start[Form], fileContent);
    AForm f = cst2ast(t);
    
    RefGraph rg = resolve(f);

}