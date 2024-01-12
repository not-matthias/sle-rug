module TestResolve

import Resolve;
import AST;
import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;


public void runAllTests(){
    RefGraph res_a = resolve(test_a());
    println(res_a);
}

public AForm test_a() {
    return form(id("qlname"), [ question( id("x-q"), "x-q-label", integer() ) ]);
}

public AForm testSimple(str input){
    Tree parsed = parse(#start[Form], input);
    return cst2ast(parsed);
}

