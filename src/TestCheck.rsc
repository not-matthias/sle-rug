module TestCheck

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;

public void runAllTests(){
    testCheck(readFile(|cwd:///examples/tests/ast.myql|));
}

public void testCheck(str input){
    Tree parsed = parse(#start[Form], input);
    AForm ast = cst2ast(parsed);
    RefGraph g = resolve(ast);
    TEnv tenv = collect(ast);
    set[Message] msgs = check(ast, tenv, g.useDef);

    // check that there are no errors
    assert msgs == {};
}

