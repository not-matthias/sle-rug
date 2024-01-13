module TestCheck

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;

public void runAllTests_Check(){

    println("TEST 1");
    set[Message] res = testCheck(readFile(|cwd:///examples/tests/check-errors.myql|));
    assert res != {};

    println("TEST 2");
    res = testCheck(readFile(|cwd:///examples/binary.myql|));

    assert !hasErrors(res);

    println("ALL TESTS PASSED");
}

public set[Message] testCheck(str input){
    Tree parsed = parse(#start[Form], input);
    AForm ast = cst2ast(parsed);
    RefGraph g = resolve(ast);
    TEnv tenv = collect(ast);

    set[Message] msgs = check(ast, tenv, g.useDef);

    return msgs;

    // check that there are no errors
    //
}

