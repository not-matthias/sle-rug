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
    println("TEST 1");
    VEnv res = testEval(readFile(|cwd:///examples/tests/eval_simple.myql|), 
                       ("x": 1
                       )
                    );
    
    println(res);
    assert res == ("x": vint(1)
                  );

    // TEST 2:
    println("TEST 2");
    res = testEval(readFile(|cwd:///examples/tests/eval_tax.myql|), 
                   ("sellingPrice": 1337
                   , "privateLoan": 420
                   )
                );
    println(res);
    assert res["valueResidue"] == vint(0);

    // TEST 3:
    println("TEST 3");
    res = testEval(readFile(|cwd:///examples/tests/eval_tax.myql|), 
                (  "sellingPrice": 1337, 
                   "privateLoan": 420,
                   "hasSoldHouse": true
                   )
                );
    println(res);
    assert res["valueResidue"] == vint(1337);
    // TEST 4:
    println("TEST 4");
    res = testEval(readFile(|cwd:///examples/tests/eval_tax.myql|), 
                (  "sellingPrice": 1337, 
                   "privateLoan": 420,
                   "privateDebt": 1000,
                   "hasSoldHouse": true
                   )
                );
    println(res);
    assert res["valueResidue"] == vint(337);

    // TEST 5:
    println("TEST 5");
    res = testEval(readFile(|cwd:///examples/binary.myql|), 
                (  "x": 0
                   )
                );
    println(res);

    println("ALL TESTS PASSED");
}

public VEnv testEval(str input_str_ql, map[str, value] inputs){
    Tree parsed = parse(#start[Form], input_str_ql);
    AForm ast = cst2ast(parsed);
    RefGraph g = resolve(ast);
    TEnv tenv = collect(ast);
    println("pre-check");
    set[Message] msgs = check(ast, tenv, g.useDef);

    // check that there are no errors in the messages
    assert !hasErrors(msgs);
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

