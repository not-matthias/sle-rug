module Presentation
import IO;
import vis::Text; //prettyTree

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import Resolve;
import Check;
import Eval;
import Transform;
import Compile;

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
    Tree cst = parse(#start[Form], fileContent);
    AForm ast = cst2ast(cst);
    
    RefGraph rg = resolve(ast);
    TEnv env = collect(ast);
    println("\nRefGraph.useDef: ");
    println(rg.useDef);

    println("\nTEnv: ");
    println(env);

    set[Message] msgs = check(ast, env, rg.useDef);

    println("\nMessages: ");
    println(msgs);

}

public void runPresentation_Eval() {
    str fileContent = readFile(|cwd:///examples/present/syntax.myql|);
    Tree cst = parse(#start[Form], fileContent);
    AForm ast = cst2ast(cst);
    RefGraph rg = resolve(ast);
    TEnv tenv = collect(ast);
    set[Message] msgs = check(ast, tenv, rg.useDef);
    assert !hasErrors(msgs);

    
    VEnv env = initialEnv(ast);
    print("Initial VEnv: ");
    println(env);

    // map
    inputs = ( "hasMaintLoan": true,
               "maintLoanAmount": 1000
            );

    // evaluate inputs
    for(k <- inputs) {
        Input i = input(k, Value_from_value(inputs[k]));
        print("evaluating input: ");
        println(i);
        env = eval(ast, i, env);
        print("VEnv after evaluation: ");
        println(env);
    }
}

public void runPresentation_Transform(){
    str fileContent = readFile(|cwd:///examples/present/flatten.myql|);
    Tree cst = parse(#start[Form], fileContent);
    AForm ast = cst2ast(cst);
    println("\n\n ---- FLATTEN TRANSFORM");
    println("\nAST: ");
    println(ast);
    
    println("\nAST after flatten: ");
    AForm flat = flatten(cst2ast(cst));
    printFlattened(flat);
    

    println("\n\n ---- RENAME TRANSFORM");
    Tree t = parse(#start[Form], readFile(|cwd:///examples/present/flatten.myql|));
    println("\nCST: ");
    println(prettyTree(t));
    
    a_loc_use = |unknown:///|(121,1,<11,7>,<11,8>);
    start[Form] renamed = rename(t, a_loc_use, "A", resolve(flat).useDef);
    println("\n: CST after rename: ");
    print(prettyTree(renamed));
}

void printFlattened(AForm flat){
    for(AQuestion q <- flat.questions){
        switch(q){
            case ifQuestion(AExpr e, list[AQuestion] qs): {
                switch(qs[0]) {
                    case question(id(name), _, _): {
                        println("question <name>: <e>");
                        continue;
                    }
                    case calculatedQuestion(id(name), _, _, _): {
                        println("question <name>: <e>");
                        continue;
                    }
                }
                throw "Unexpected question type, inner should be question";
            }
        }
    }

}


public void runPresentation_Compile() {
     Tree parsed = parse(#start[Form], |project://sle-rug/examples/present/compile.myql|);
    AForm f = cst2ast(parsed);
    RefGraph g = resolve(f);
    TEnv tenv = collect(f);

    set[Message] msgs = check(f, tenv, g.useDef);
    assert !hasErrors(msgs);

    compile(f);
}