module TestSyntax
import Syntax;
import ParseTree;
import IO;

public void runAllTests(){
    str fileContent = readFile(|file:///Users/tobiaspucher/GitHub/sle-rug/examples/tests/simple.myql|);
    Tree t = testSimple(fileContent);
    println(t);
}

public Tree testSimple(str input){
    Tree res = parse(#start[Form], input);
    return res;
}
