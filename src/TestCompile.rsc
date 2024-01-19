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
    testCompile(|project://sle-rug/examples/errors.myql|);

    // TODO: Other tests for all expressions (boolean and math -> conditional)
}

public void testCompile(loc input){
    Tree parsed = parse(#start[Form], input);
    AForm f = cst2ast(parsed);

    compile(f);
}
