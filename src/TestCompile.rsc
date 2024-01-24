module TestCompile

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;


import Compile;

public void runAllTests_Compile(){
    testCompile(|project://sle-rug/examples/binary.myql|);
    testCompile(|project://sle-rug/examples/tax.myql|);
    testCompile(|project://sle-rug/examples/cyclic.myql|);
    testCompile(|project://sle-rug/examples/empty.myql|);
    testCompile(|project://sle-rug/examples/tests/compile/boolean_if.myql|);
    testCompile(|project://sle-rug/examples/tests/compile/compile_simple.myql|);
    testCompile(|project://sle-rug/examples/tests/compile/x_in_two_blocks.myql|);
}

public void testCompile(loc input){
    Tree parsed = parse(#start[Form], input);
    AForm f = cst2ast(parsed);

    RefGraph g = resolve(f);
    TEnv tenv = collect(f);

    set[Message] msgs = check(f, tenv, g.useDef);
    assert !hasErrors(msgs);

    compile(f);
}
