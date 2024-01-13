module TestEval

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;

import Eval;

public void runAllTests_Eval(){
    // TEST 1: 
    VEnv res = testEval(readFile(|cwd:///examples/tests/eval_simple.myql|), 
                       ("x": 1
                       )
                    );
    
    print("TEST 1 res: ");
    println(res);
    assert res == ("x": vint(1)
                  );
}

public VEnv testEval(str input_str_ql, map[str, value] inputs){
    Tree parsed = parse(#start[Form], input_str_ql);
    AForm ast = cst2ast(parsed);
    RefGraph g = resolve(ast);
    TEnv tenv = collect(ast);
    println("pre-check");
    set[Message] msgs = check(ast, tenv, g.useDef);

    // check that there are no errors
    assert msgs == {};
    println("post-check");
    
    println("pre-eval");
    VEnv env = initialEnv(ast);
    print("initial ev: ");
    println(env);

    // evaluate inputs
    for(k <- inputs) {
        Input i = input(k, Value_from_value(inputs[k]));
        print("eval input: ");
        println(i);
        env = eval(ast, i, env);
    }
    println("post-eval");

    return env;
}

