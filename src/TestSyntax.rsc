module TestSyntax
import Syntax;
import ParseTree;
import IO;
import vis::Text; //prettyTree

public void runAllTests(){
    str fileContent = readFile(|cwd:///examples/tests/syntax.myql|);
    Tree t = testSimple(fileContent);
    println("Tree: ");
    println(t);
    println("Pretty Tree: ");
    println(prettyTree(t));
}

public Tree testSimple(str input){
    Tree res = parse(#start[Form], input);
    return res;
}

