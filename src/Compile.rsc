module Compile

import AST;
import Resolve;
import Transform;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;
import Boolean;
import util::Math;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}


// HTML related code
//

HTMLElement form2html(AForm f) {
  HTMLElement scriptSrc = script([]);
  scriptSrc.src = f.src[extension="js"].file;

  HTMLElement head = head([
    title([text(f.name.name)]),
    scriptSrc
  ]);

  list[HTMLElement] questions = [];
  for(AQuestion q <- f.questions) {
    questions += question2html(q);
  }

  HTMLElement submit = button([text("Submit")]);
  submit.\type = "submit";

  return html([head, body([form(questions), submit])]);
}

HTMLElement question2html (AQuestion q) {
  list[HTMLElement] content = [];

  if (q is question || q is calculatedQuestion) {
      content += h3([text(q.label)]);
      content += input2html(q);
      content += br();

      return div(content, id = "div_<q.id.name>");
  }
  
  if (q is ifQuestion || q is ifElseQuestion) {
    str blockStyle = "margin: 20px; padding: 10px; border: 2px solid black";

    // If block
    content += h3([text("if " + expr2str(q.expr) + " {")]);
    content += div([question2html(q) | AQuestion q <- q.ifQuestions], style = blockStyle);

    // Else block
    if (q is ifElseQuestion) {
      content += h3([text("} else {")]);
      content += div([question2html(q) | AQuestion q <- q.elseQuestions], style = blockStyle);
    }

    // Close the if/else block
    content += h3([text("}")]);
  }

  return div(content);
}

str expr2str(AExpr expr) {
  switch (expr) {
    case ref(id(str x)): return x;
    case intLit(int x): return toString(x);
    case strLit(str x): return x;
    case boolLit(bool x): return toString(x);
    case add(lhs, rhs): return (expr2str(lhs) + " + " + expr2str(rhs));
    case sub(lhs, rhs): return (expr2str(lhs) + " - " + expr2str(rhs));
    case mul(lhs, rhs): return (expr2str(lhs) + " * " + expr2str(rhs));
    case div(lhs, rhs): return (expr2str(lhs) + " / " + expr2str(rhs));
    // boolean expressions
    case not(lhs): return ("!" + expr2str(lhs));
    case and(lhs, rhs): return (expr2str(lhs) + " && " + expr2str(rhs));
    case or(lhs, rhs): return (expr2str(lhs) + " || " + expr2str(rhs));
    case equal(lhs, rhs): return  (expr2str(lhs) + " == " + expr2str(rhs));
    case neq(lhs, rhs): return (expr2str(lhs) + " != " + expr2str(rhs));
    case lt(lhs, rhs): return  (expr2str(lhs) + " \< " + expr2str(rhs));
    case lte(lhs, rhs): return (expr2str(lhs) + " \<= " + expr2str(rhs));
    case gt(lhs, rhs): return  (expr2str(lhs) + " \> " + expr2str(rhs));
    case gte(lhs, rhs): return (expr2str(lhs) + " \>= " + expr2str(rhs));
    default: throw "Unhandled expr <expr>";
  }
}

HTMLElement input2html(AQuestion q) {
  str inputType = "";
  switch(q.qtype) {
      case integer(): inputType = "number";
      case boolean(): inputType = "checkbox";
      case string(): inputType = "text";
  };

  str id = q.id.name;
  str onChange = "onChange_" + q.id.name + "(this)";
  
  HTMLElement i = input(\type = inputType, id = id, onchange = onChange);

  // Disable if it's a computed question
  if (q is calculatedQuestion) {
    i.disabled = "true";
  }

  return i;
}

// Javascript related code
//

str call_event_handlers(AQuestion q, UseDef useDef, AForm f) {
  set[str] code = {};

  // Try to find all possible usages of the current value
  loc qSrc = q.id.src;
  for (<loc usage, qSrc> <- useDef) {

    // Find the question where the definition came from
    for (/AQuestion q <- f) {
      for (/AId id <- q, id.src == usage) {
        // Call the update handler for computed and conditional questions.
        if (q is calculatedQuestion) {
          code += "update_<q.id.name>();";
        } else if (q is ifQuestion || q is ifElseQuestion) {
          code += "update_conditions();";
        }
      }
    }
  }

  str finalCode = "";
  for (str c <- code) {
    finalCode += c;
  }
  return finalCode;
}


str default_value(AType qtype) {
  switch (qtype) {
    case integer(): return "0";
    case boolean(): return "false";
    case string(): return "\"\"";
    default: return "UNREACHABLE";
  }
}

str parse_value(AType qtype, str code) {
  switch (qtype) {
    case integer(): return "parseInt(<code>)";
    case boolean(): return "<code>";
    case string(): return  "<code>";
    default: return "UNREACHABLE";
  }
}

str set_value(AType qtype) {
   switch (qtype) {
    case integer(): return "input.value = ";
    case boolean(): return "input.checked = ";
    case string(): return  "input.value =";
    default: return "UNREACHABLE";
  }
}


// Generate all the variables at once, so that we don't get 
// the error:
// 
// 'Uncaught ReferenceError: can't access lexical declaration 'x_3_4' before initialization'
// 
str generate_vars(AForm f) {
  str code = "";
  
  for (/AQuestion q <- f, q is question) {
    str varName = q.id.name;
    code += "let <varName> = <default_value(q.qtype)>;";
  }

  return code;
}

str generate_question(AQuestion q, UseDef useDef, AForm f) {
  if (q is question) {
    str inputId = q.id.name;
    str funName = "onChange_<inputId>";
    str varName = inputId;
    str field = (q.qtype is boolean) ? "input.checked" : "input.value";

    str content = "";
    content += "function <funName> (input) {";
    content += "<varName> = <parse_value(q.qtype, field)>;";
    content += "console.log(<varName>);";
    content += call_event_handlers(q, useDef, f);
    content += "}";
    content += "\n\n";

    return content;
  }

  if (q is calculatedQuestion) {
    str inputId = q.id.name;
    str funName = "update_<inputId>";
    str varName = "input_<inputId>";
    str field = (q.qtype is boolean) ? "checked" : "value";

    str content = "";
    content += "function <funName>() {";
    content += "let <varName> = document.querySelector(\"#<inputId>\");";
    content += "<varName>.<field> = <expr2str(q.expr)>;";
    content += "console.log(<varName>);";
    content += "}";

    // Execute the update handler (to initialize the default value) after the DOM was loaded
    content += "document.addEventListener(\"DOMContentLoaded\", () =\> <funName>());";

    return content;
  }

  return "";
}

str generate_questions(AForm f) {
  str code = "";

  RefGraph refGraph = resolve(f);
  for (/AQuestion q <- f) {
    code += generate_question(q, refGraph.useDef, f);
  }

  return code;
}

str display_question(AQuestion q, bool show) {
  str displayValue = show ? "block" : "none";
  str element = "document.querySelector(\"#div_<q.id.name>\")";
  return "<element>.style.display = \"<displayValue>\";";
}

str display_questions(list[AQuestion] questions, bool show) {
    str code = "";
    for (AQuestion q <- questions, q is question || q is calculatedQuestion) {
      code += display_question(q, show);
    }
    return code;
}

str recursive_display_questions(list[AQuestion] questions, bool show) {
    str code = "";
    for (/AQuestion q <- questions, q is question || q is calculatedQuestion) {
      code += display_question(q, show);
    }
    return code;
}

str generate_conditional_questions(AForm f) {
  str content = "";

  content += "function update_conditions() {";
  content += "console.log(\"updating conditions\");";
  for(/AQuestion q <- f) {
    if (q is ifQuestion) {
      content += "if (<expr2str(q.expr)>) {";
      content += display_questions(q.ifQuestions, true);
      content += "} else {";
      content += recursive_display_questions(q.ifQuestions, false);
      content += "}";
    }

    if (q is ifElseQuestion) {
      content += "if (<expr2str(q.expr)>) {";
      content += display_questions(q.ifQuestions, true);
      content += recursive_display_questions(q.elseQuestions, false);
      content += "} else {";
      content += recursive_display_questions(q.ifQuestions, false);
      content += display_questions(q.elseQuestions, true);
      content += "}";
    }
  }
  content += "}";

  return content;
}

str form2js(AForm f) {
  str content = "";
  content += "console.log(\"Loaded script\");";
  content += generate_vars(f);
  content += generate_conditional_questions(f);
  content += generate_questions(f);

  // Initialize the conditional questions by calling the update method once the DOM was loaded
  content += "document.addEventListener(\"DOMContentLoaded\", () =\> update_conditions());";

  return content;
}
