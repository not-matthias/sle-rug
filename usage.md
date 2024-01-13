# Week 2

```
import Syntax;
import TestSyntax;
runAllTests();
```

# Week 3

```
import Syntax;
import AST;
import CST2AST;
import TestAST;

runAllTests();
```

# Week 4

```
import Check;
import Resolve;
import TestCheck;

runAllTests();
```

Add the following to vscode config if errors and hints are not shown: 

```json
// settings.json
    "[parametric-rascalmpl]": {
        
        "editor.colorDecorators": true,
        "editor.semanticHighlighting.enabled": true,
        "editor.showUnused": true,
        "editor.showDeprecated": true

    }
```