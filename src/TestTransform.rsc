module TestTransform

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;

import Transform;

public void runAllTests_Transform(){
    AForm t = testSimple(readFile(|cwd:///examples/tests/flatten.myql|));
    println("AForm: ");
    println(t);
    
    AForm flat = flatten(t);
    printFlattened(flat);

}

void printFlattened(AForm flat){
    println("Flattened: ");
    for(AQuestion q <- flat.questions){
        switch(q){
            case ifQuestion(AExpr e, list[AQuestion] qs): {
                switch(qs[0]) {
                    case question(id(name), _, _): {
                        println("Flat question id <name>: <e>");
                        continue;
                    }
                    case calculatedQuestion(id(name), _, _, _): {
                        println("Flat calculatedQuestion id <name>: <e>");
                        continue;
                    }
                }
                throw "Unexpected question type, inner should be question";
            }
        }
    }

}


public AForm testSimple(str input){
    Tree parsed = parse(#start[Form], input);
    return cst2ast(parsed);
}

