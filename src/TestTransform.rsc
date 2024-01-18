module TestTransform

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Resolve;
import vis::Text; //prettyTree
import Transform;

public void runAllTests_Transform(){
    t = parse(#start[Form], readFile(|cwd:///examples/tests/flatten.myql|));
     
    AForm flat = flatten(cst2ast(t));
    printFlattened(flat);


    t = parse(#start[Form], readFile(|cwd:///examples/tests/flatten.myql|));

    a_loc_use = |unknown:///|(121,1,<11,7>,<11,8>);
    
    print(prettyTree(t));

    start[Form] renamed = rename(t, a_loc_use, "A", resolve(flat).useDef);

    print(prettyTree(renamed));
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

