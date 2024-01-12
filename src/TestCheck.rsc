module TestCheck

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;

public void runAllTests(){
    println("TestCheck runAllTests begin");
    testCheck(readFile(|cwd:///examples/tests/check-errors.myql|));
}

public void testCheck(str input){
    Tree parsed = parse(#start[Form], input);
    AForm ast = cst2ast(parsed);
    RefGraph g = resolve(ast);
    TEnv tenv = collect(ast);
    println("pre-check");
    set[Message] msgs = check(ast, tenv, g.useDef);
    println("post-check");

    println(msgs);

    // check that there are no errors
    //assert msgs == {};
}

