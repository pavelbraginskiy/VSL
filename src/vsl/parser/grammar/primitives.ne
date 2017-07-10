# Parses basic primitives

@{%
function recursiveType(types, optional, location) {
  for (let i = 1; i < types.length; i++)
    types[i] = new t.Type(types[i - 1], types[i], false, location);
  types[types.length - 1].optional = optional;
  return types[types.length - 1];
}
function recursiveTypeDeclaration(types, optional, parent, fallback, location) {
  for (let i = 1; i < types.length; i++)
    types[i] = new t.TypeDeclaration(types[i - 1], types[i], false, null, location);
  types[types.length - 1].optional = optional;
  types[types.length - 1].parent = parent;
  types[types.length - 1].fallback = fallback;
  return types[types.length - 1];
}
%}

TypedIdentifier -> Identifier (_ ":" _ type {% nth(3) %}):? {% (d, l) => new t.TypedIdentifier(d[0], d[1], l) %}
type -> delimited[className {% id  %}, _ "." _] "?":? {% (d, l) => recursiveType(d[0], !!d[1], l) %}
className -> Identifier {% id %}
           | Identifier "[" "]" {% (d, l) => new t.Generic(new t.Identifier("Array", false, l), [d[0]], l) %}
           | Identifier "<" delimited[type {% id %}, _ "," _] ">" {% (d, l) => new t.Generic(d[0], d[2], l) %}
           # TODO: location is incorrect for inner type
           | Identifier "<" Identifier "<" delimited[type {% id %}, _ "," _] ">>" {% (d, l) => new t.Generic(d[0], [new t.Generic(d[2], d[4], l)], l) %}
           | Identifier "<" delimited[type {% id %}, _ "," _] "," Identifier "<" delimited[type {% id %}, _ "," _] ">>" {% (d, l) => new t.Generic(d[0], d[2].concat([new t.Generic(d[4], d[6], l)]), l) %}

typeDeclaration -> delimited[classDeclaration {% id %}, _ "." _] "?":? (":" delimited[classDeclaration {% id %}, _ "." _] "?":? {% (d, l) => recursiveTypeDeclaration(d[1], !!d[2], null, null, l) %}):? ("=" type {% nth(1) %}):? {% (d, l) => recursiveTypeDeclaration(d[0], !!d[1], d[2], d[3], l) %}
classDeclaration -> Identifier {% id %}
                  | Identifier "[" "]" {% (d, l) => new t.GenericDeclaration(new t.Identifier("Array", false, l), [d[0]], l) %}
                  | Identifier "<" delimited[typeDeclaration {% id %}, _ "," _] ">" {% (d, l) => new t.GenericDeclaration(d[0], d[2], l) %}
                  | Identifier "<" Identifier "<" delimited[typeDeclaration {% id %}, _ "," _] ">>" {% (d, l) => new t.GenericDeclaration(d[0], [new t.GenericDeclaration(d[2], d[4], l)], l) %}
                  | Identifier "<" delimited[typeDeclaration {% id %}, _ "," _] "," Identifier "<" delimited[typeDeclaration {% id %}, _ "," _] ">>" {% (d, l) => new t.GenericDeclaration(d[0], d[2].concat([new t.GenericDeclaration(d[4], d[6], l)]), l) %}

# TODO: whitespace between modifier and typealias

TypeAlias -> Modifier "typealias" _ Identifier _ "=" _ type {% (d, l) => new t.TypeAlias(d[0], d[4], d[8], l) %}

# Identifier
Identifier -> %identifier {% (d, l) => new t.Identifier(d[0][0], l) %}
