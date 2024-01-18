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
  // writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(|cwd:///out.html|, writeHTMLString(form2html(f)));
  // writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

HTMLElement form2html(AForm f) {
  HTMLElement head = head([
    title([text("QL Form")])
  ]);
  // TODO: import js

  list[HTMLElement] questions = [];
  for(/AQuestion q <- f) {
    questions += question2html(q);
  }

  HTMLElement submit = button([text("Submit")]);
  submit.\type = "submit";

  return html([head] + questions + [submit]);
}

list[HTMLElement] question2html (AQuestion q) {
  list[HTMLElement] content = [];

  if (q is question || q is calculatedQuestion) {
      content += h3([text(q.label)]);
      content += input2html(q);
      content += br();
      return content;
  }

  // q is either ifQuestion or ifElseQuestion
  
  str blockStyle = "padding: 30px; border: 2px solid black";

  // If block
  content += h3([text("if " + expr2str(q.expr) + " {")]);
  content += [div(question2html(q), style = blockStyle) | AQuestion q <- q.ifQuestions];

  // Else block
  if (q is ifElseQuestion) {
    content += h3([text("} else {")]);
    content += [div(question2html(q), style = blockStyle) | AQuestion q <- q.elseQuestions];
  }

  // Close the if/else block
  content += h3([text("}")]);

  return content;
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
    case eq(lhs, rhs): return  (expr2str(lhs) + " == " + expr2str(rhs));
    case neq(lhs, rhs): return (expr2str(lhs) + " != " + expr2str(rhs));
    case lt(lhs, rhs): return  (expr2str(lhs) + " < " + expr2str(rhs));
    case lte(lhs, rhs): return (expr2str(lhs) + " <= " + expr2str(rhs));
    case gt(lhs, rhs): return  (expr2str(lhs) + " > " + expr2str(rhs));
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
  str onClick = "onClick_" + q.id.name;
  
  HTMLElement input = input(\type = inputType, id = id, onclick = onClick);

  // Disable if it's a computed question
  if (q is calculatedQuestion) {
    input.disabled = "true";
  }

  return input;
}

str form2js(AForm f) {
  return "// this is a test";
}
