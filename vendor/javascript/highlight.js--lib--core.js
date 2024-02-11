var e={};function deepFreeze(e){e instanceof Map?e.clear=e.delete=e.set=function(){throw new Error("map is read-only")}:e instanceof Set&&(e.add=e.clear=e.delete=function(){throw new Error("set is read-only")});Object.freeze(e);Object.getOwnPropertyNames(e).forEach((t=>{const n=e[t];const i=typeof n;"object"!==i&&"function"!==i||Object.isFrozen(n)||deepFreeze(n)}));return e}
/** @typedef {import('highlight.js').CallbackResponse} CallbackResponse */
/** @typedef {import('highlight.js').CompiledMode} CompiledMode */class Response{
/**
   * @param {CompiledMode} mode
   */
constructor(e){void 0===e.data&&(e.data={});this.data=e.data;this.isMatchIgnored=false}ignoreMatch(){this.isMatchIgnored=true}}
/**
 * @param {string} value
 * @returns {string}
 */function escapeHTML(e){return e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#x27;")}
/**
 * performs a shallow merge of multiple objects into one
 *
 * @template T
 * @param {T} original
 * @param {Record<string,any>[]} objects
 * @returns {T} a single new object
 */function inherit$1(e,...t){
/** @type Record<string,any> */
const n=Object.create(null);for(const t in e)n[t]=e[t];t.forEach((function(e){for(const t in e)n[t]=e[t]}));/** @type {T} */
return n}
/**
 * @typedef {object} Renderer
 * @property {(text: string) => void} addText
 * @property {(node: Node) => void} openNode
 * @property {(node: Node) => void} closeNode
 * @property {() => string} value
 */
/** @typedef {{scope?: string, language?: string, sublanguage?: boolean}} Node */
/** @typedef {{walk: (r: Renderer) => void}} Tree */const t="</span>";
/**
 * Determines if a node needs to be wrapped in <span>
 *
 * @param {Node} node */const emitsWrappingTags=e=>!!e.scope;
/**
 *
 * @param {string} name
 * @param {{prefix:string}} options
 */const scopeToCSSClass=(e,{prefix:t})=>{if(e.startsWith("language:"))return e.replace("language:","language-");if(e.includes(".")){const n=e.split(".");return[`${t}${n.shift()}`,...n.map(((e,t)=>`${e}${"_".repeat(t+1)}`))].join(" ")}return`${t}${e}`};
/** @type {Renderer} */class HTMLRenderer{
/**
   * Creates a new HTMLRenderer
   *
   * @param {Tree} parseTree - the parse tree (must support `walk` API)
   * @param {{classPrefix: string}} options
   */
constructor(e,t){this.buffer="";this.classPrefix=t.classPrefix;e.walk(this)}
/**
   * Adds texts to the output stream
   *
   * @param {string} text */addText(e){this.buffer+=escapeHTML(e)}
/**
   * Adds a node open to the output stream (if needed)
   *
   * @param {Node} node */openNode(e){if(!emitsWrappingTags(e))return;const t=scopeToCSSClass(e.scope,{prefix:this.classPrefix});this.span(t)}
/**
   * Adds a node close to the output stream (if needed)
   *
   * @param {Node} node */closeNode(e){emitsWrappingTags(e)&&(this.buffer+=t)}value(){return this.buffer}
/**
   * Builds a span element
   *
   * @param {string} className */
span(e){this.buffer+=`<span class="${e}">`}}
/** @typedef {{scope?: string, language?: string, children: Node[]} | string} Node */
/** @typedef {{scope?: string, language?: string, children: Node[]} } DataNode */
/** @typedef {import('highlight.js').Emitter} Emitter */
/** @returns {DataNode} */const newNode=(e={})=>{
/** @type DataNode */
const t={children:[]};Object.assign(t,e);return t};class TokenTree{constructor(){
/** @type DataNode */
this.rootNode=newNode();this.stack=[this.rootNode]}get top(){return this.stack[this.stack.length-1]}get root(){return this.rootNode}
/** @param {Node} node */add(e){this.top.children.push(e)}
/** @param {string} scope */openNode(e){
/** @type Node */
const t=newNode({scope:e});this.add(t);this.stack.push(t)}closeNode(){if(this.stack.length>1)return this.stack.pop()}closeAllNodes(){while(this.closeNode());}toJSON(){return JSON.stringify(this.rootNode,null,4)}
/**
   * @typedef { import("./html_renderer").Renderer } Renderer
   * @param {Renderer} builder
   */walk(e){return this.constructor._walk(e,this.rootNode)}
/**
   * @param {Renderer} builder
   * @param {Node} node
   */static _walk(e,t){if("string"===typeof t)e.addText(t);else if(t.children){e.openNode(t);t.children.forEach((t=>this._walk(e,t)));e.closeNode(t)}return e}
/**
   * @param {Node} node
   */static _collapse(e){"string"!==typeof e&&e.children&&(e.children.every((e=>"string"===typeof e))?e.children=[e.children.join("")]:e.children.forEach((e=>{TokenTree._collapse(e)})))}}class TokenTreeEmitter extends TokenTree{
/**
   * @param {*} options
   */
constructor(e){super();this.options=e}
/**
   * @param {string} text
   */addText(e){""!==e&&this.add(e)}
/** @param {string} scope */startScope(e){this.openNode(e)}endScope(){this.closeNode()}
/**
   * @param {Emitter & {root: DataNode}} emitter
   * @param {string} name
   */__addSublanguage(e,t){
/** @type DataNode */
const n=e.root;t&&(n.scope=`language:${t}`);this.add(n)}toHTML(){const e=new HTMLRenderer(this,this.options);return e.value()}finalize(){this.closeAllNodes();return true}}
/**
 * @param {string} value
 * @returns {RegExp}
 * */
/**
 * @param {RegExp | string } re
 * @returns {string}
 */function source(e){return e?"string"===typeof e?e:e.source:null}
/**
 * @param {RegExp | string } re
 * @returns {string}
 */function lookahead(e){return concat("(?=",e,")")}
/**
 * @param {RegExp | string } re
 * @returns {string}
 */function anyNumberOfTimes(e){return concat("(?:",e,")*")}
/**
 * @param {RegExp | string } re
 * @returns {string}
 */function optional(e){return concat("(?:",e,")?")}
/**
 * @param {...(RegExp | string) } args
 * @returns {string}
 */function concat(...e){const t=e.map((e=>source(e))).join("");return t}
/**
 * @param { Array<string | RegExp | Object> } args
 * @returns {object}
 */function stripOptionsFromArgs(e){const t=e[e.length-1];if("object"===typeof t&&t.constructor===Object){e.splice(e.length-1,1);return t}return{}}
/** @typedef { {capture?: boolean} } RegexEitherOptions */
/**
 * Any of the passed expresssions may match
 *
 * Creates a huge this | this | that | that match
 * @param {(RegExp | string)[] | [...(RegExp | string)[], RegexEitherOptions]} args
 * @returns {string}
 */function either(...e){
/** @type { object & {capture?: boolean} }  */
const t=stripOptionsFromArgs(e);const n="("+(t.capture?"":"?:")+e.map((e=>source(e))).join("|")+")";return n}
/**
 * @param {RegExp | string} re
 * @returns {number}
 */function countMatchGroups(e){return new RegExp(e.toString()+"|").exec("").length-1}
/**
 * Does lexeme start with a regular expression match at the beginning
 * @param {RegExp} re
 * @param {string} lexeme
 */function startsWith(e,t){const n=e&&e.exec(t);return n&&0===n.index}const n=/\[(?:[^\\\]]|\\.)*\]|\(\??|\\([1-9][0-9]*)|\\./;
/**
 * @param {(string | RegExp)[]} regexps
 * @param {{joinWith: string}} opts
 * @returns {string}
 */function _rewriteBackreferences(e,{joinWith:t}){let i=0;return e.map((e=>{i+=1;const t=i;let o=source(e);let s="";while(o.length>0){const e=n.exec(o);if(!e){s+=o;break}s+=o.substring(0,e.index);o=o.substring(e.index+e[0].length);if("\\"===e[0][0]&&e[1])s+="\\"+String(Number(e[1])+t);else{s+=e[0];"("===e[0]&&i++}}return s})).map((e=>`(${e})`)).join(t)}
/** @typedef {import('highlight.js').Mode} Mode */
/** @typedef {import('highlight.js').ModeCallback} ModeCallback */const i=/\b\B/;const o="[a-zA-Z]\\w*";const s="[a-zA-Z_]\\w*";const r="\\b\\d+(\\.\\d+)?";const a="(-?)(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)";const c="\\b(0b[01]+)";const l="!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|-|-=|/=|/|:|;|<<|<<=|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~";
/**
* @param { Partial<Mode> & {binary?: string | RegExp} } opts
*/const SHEBANG=(e={})=>{const t=/^#![ ]*\//;e.binary&&(e.begin=concat(t,/.*\b/,e.binary,/\b.*/));return inherit$1({scope:"meta",begin:t,end:/$/,relevance:0,
/** @type {ModeCallback} */
"on:begin":(e,t)=>{0!==e.index&&t.ignoreMatch()}},e)};const g={begin:"\\\\[\\s\\S]",relevance:0};const u={scope:"string",begin:"'",end:"'",illegal:"\\n",contains:[g]};const h={scope:"string",begin:'"',end:'"',illegal:"\\n",contains:[g]};const d={begin:/\b(a|an|the|are|I'm|isn't|don't|doesn't|won't|but|just|should|pretty|simply|enough|gonna|going|wtf|so|such|will|you|your|they|like|more)\b/};
/**
 * Creates a comment mode
 *
 * @param {string | RegExp} begin
 * @param {string | RegExp} end
 * @param {Mode | {}} [modeOptions]
 * @returns {Partial<Mode>}
 */const COMMENT=function(e,t,n={}){const i=inherit$1({scope:"comment",begin:e,end:t,contains:[]},n);i.contains.push({scope:"doctag",begin:"[ ]*(?=(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):)",end:/(TODO|FIXME|NOTE|BUG|OPTIMIZE|HACK|XXX):/,excludeBegin:true,relevance:0});const o=either("I","a","is","so","us","to","at","if","in","it","on",/[A-Za-z]+['](d|ve|re|ll|t|s|n)/,/[A-Za-z]+[-][a-z]+/,/[A-Za-z][a-z]{2,}/);i.contains.push({begin:concat(/[ ]+/,"(",o,/[.]?[:]?([.][ ]|[ ])/,"){3}")});return i};const f=COMMENT("//","$");const p=COMMENT("/\\*","\\*/");const m=COMMENT("#","$");const b={scope:"number",begin:r,relevance:0};const w={scope:"number",begin:a,relevance:0};const E={scope:"number",begin:c,relevance:0};const x={scope:"regexp",begin:/\/(?=[^/\n]*\/)/,end:/\/[gimuy]*/,contains:[g,{begin:/\[/,end:/\]/,relevance:0,contains:[g]}]};const y={scope:"title",begin:o,relevance:0};const M={scope:"title",begin:s,relevance:0};const _={begin:"\\.\\s*"+s,relevance:0};
/**
 * Adds end same as begin mechanics to a mode
 *
 * Your mode must include at least a single () match group as that first match
 * group is what is used for comparison
 * @param {Partial<Mode>} mode
 */const END_SAME_AS_BEGIN=function(e){return Object.assign(e,{
/** @type {ModeCallback} */
"on:begin":(e,t)=>{t.data._beginMatch=e[1]},
/** @type {ModeCallback} */
"on:end":(e,t)=>{t.data._beginMatch!==e[1]&&t.ignoreMatch()}})};var k=Object.freeze({__proto__:null,APOS_STRING_MODE:u,BACKSLASH_ESCAPE:g,BINARY_NUMBER_MODE:E,BINARY_NUMBER_RE:c,COMMENT:COMMENT,C_BLOCK_COMMENT_MODE:p,C_LINE_COMMENT_MODE:f,C_NUMBER_MODE:w,C_NUMBER_RE:a,END_SAME_AS_BEGIN:END_SAME_AS_BEGIN,HASH_COMMENT_MODE:m,IDENT_RE:o,MATCH_NOTHING_RE:i,METHOD_GUARD:_,NUMBER_MODE:b,NUMBER_RE:r,PHRASAL_WORDS_MODE:d,QUOTE_STRING_MODE:h,REGEXP_MODE:x,RE_STARTERS_RE:l,SHEBANG:SHEBANG,TITLE_MODE:y,UNDERSCORE_IDENT_RE:s,UNDERSCORE_TITLE_MODE:M});
/**
@typedef {import('highlight.js').CallbackResponse} CallbackResponse
@typedef {import('highlight.js').CompilerExt} CompilerExt
*/
/**
 * Skip a match if it has a preceding dot
 *
 * This is used for `beginKeywords` to prevent matching expressions such as
 * `bob.keyword.do()`. The mode compiler automatically wires this up as a
 * special _internal_ 'on:begin' callback for modes with `beginKeywords`
 * @param {RegExpMatchArray} match
 * @param {CallbackResponse} response
 */function skipIfHasPrecedingDot(e,t){const n=e.input[e.index-1];"."===n&&t.ignoreMatch()}
/**
 *
 * @type {CompilerExt}
 */function scopeClassName(e,t){if(void 0!==e.className){e.scope=e.className;delete e.className}}
/**
 * `beginKeywords` syntactic sugar
 * @type {CompilerExt}
 */function beginKeywords(e,t){if(t&&e.beginKeywords){e.begin="\\b("+e.beginKeywords.split(" ").join("|")+")(?!\\.)(?=\\b|\\s)";e.__beforeBegin=skipIfHasPrecedingDot;e.keywords=e.keywords||e.beginKeywords;delete e.beginKeywords;void 0===e.relevance&&(e.relevance=0)}}
/**
 * Allow `illegal` to contain an array of illegal values
 * @type {CompilerExt}
 */function compileIllegal(e,t){Array.isArray(e.illegal)&&(e.illegal=either(...e.illegal))}
/**
 * `match` to match a single expression for readability
 * @type {CompilerExt}
 */function compileMatch(e,t){if(e.match){if(e.begin||e.end)throw new Error("begin & end are not supported with match");e.begin=e.match;delete e.match}}
/**
 * provides the default 1 relevance to all modes
 * @type {CompilerExt}
 */function compileRelevance(e,t){void 0===e.relevance&&(e.relevance=1)}const beforeMatchExt=(e,t)=>{if(!e.beforeMatch)return;if(e.starts)throw new Error("beforeMatch cannot be used with starts");const n=Object.assign({},e);Object.keys(e).forEach((t=>{delete e[t]}));e.keywords=n.keywords;e.begin=concat(n.beforeMatch,lookahead(n.begin));e.starts={relevance:0,contains:[Object.assign(n,{endsParent:true})]};e.relevance=0;delete n.beforeMatch};const O=["of","and","for","in","not","or","if","then","parent","list","value"];const R="keyword";
/**
 * Given raw keywords from a language definition, compile them.
 *
 * @param {string | Record<string,string|string[]> | Array<string>} rawKeywords
 * @param {boolean} caseInsensitive
 */function compileKeywords(e,t,n=R){
/** @type {import("highlight.js/private").KeywordDict} */
const i=Object.create(null);"string"===typeof e?compileList(n,e.split(" ")):Array.isArray(e)?compileList(n,e):Object.keys(e).forEach((function(n){Object.assign(i,compileKeywords(e[n],t,n))}));return i;
/**
   * Compiles an individual list of keywords
   *
   * Ex: "for if when while|5"
   *
   * @param {string} scopeName
   * @param {Array<string>} keywordList
   */function compileList(e,n){t&&(n=n.map((e=>e.toLowerCase())));n.forEach((function(t){const n=t.split("|");i[n[0]]=[e,scoreForKeyword(n[0],n[1])]}))}}
/**
 * Returns the proper score for a given keyword
 *
 * Also takes into account comment keywords, which will be scored 0 UNLESS
 * another score has been manually assigned.
 * @param {string} keyword
 * @param {string} [providedScore]
 */function scoreForKeyword(e,t){return t?Number(t):commonKeyword(e)?0:1}
/**
 * Determines if a given keyword is common or not
 *
 * @param {string} keyword */function commonKeyword(e){return O.includes(e.toLowerCase())}
/**
 * @type {Record<string, boolean>}
 */const N={};
/**
 * @param {string} message
 */const error=e=>{console.error(e)};
/**
 * @param {string} message
 * @param {any} args
 */const warn=(e,...t)=>{console.log(`WARN: ${e}`,...t)};
/**
 * @param {string} version
 * @param {string} message
 */const deprecated=(e,t)=>{if(!N[`${e}/${t}`]){console.log(`Deprecated as of ${e}. ${t}`);N[`${e}/${t}`]=true}};
/**
@typedef {import('highlight.js').CompiledMode} CompiledMode
*/const L=new Error;
/**
 * Renumbers labeled scope names to account for additional inner match
 * groups that otherwise would break everything.
 *
 * Lets say we 3 match scopes:
 *
 *   { 1 => ..., 2 => ..., 3 => ... }
 *
 * So what we need is a clean match like this:
 *
 *   (a)(b)(c) => [ "a", "b", "c" ]
 *
 * But this falls apart with inner match groups:
 *
 * (a)(((b)))(c) => ["a", "b", "b", "b", "c" ]
 *
 * Our scopes are now "out of alignment" and we're repeating `b` 3 times.
 * What needs to happen is the numbers are remapped:
 *
 *   { 1 => ..., 2 => ..., 5 => ... }
 *
 * We also need to know that the ONLY groups that should be output
 * are 1, 2, and 5.  This function handles this behavior.
 *
 * @param {CompiledMode} mode
 * @param {Array<RegExp | string>} regexes
 * @param {{key: "beginScope"|"endScope"}} opts
 */function remapScopeNames(e,t,{key:n}){let i=0;const o=e[n];
/** @type Record<number,boolean> */const s={};
/** @type Record<number,string> */const r={};for(let e=1;e<=t.length;e++){r[e+i]=o[e];s[e+i]=true;i+=countMatchGroups(t[e-1])}e[n]=r;e[n]._emit=s;e[n]._multi=true}
/**
 * @param {CompiledMode} mode
 */function beginMultiClass(e){if(Array.isArray(e.begin)){if(e.skip||e.excludeBegin||e.returnBegin){error("skip, excludeBegin, returnBegin not compatible with beginScope: {}");throw L}if("object"!==typeof e.beginScope||null===e.beginScope){error("beginScope must be object");throw L}remapScopeNames(e,e.begin,{key:"beginScope"});e.begin=_rewriteBackreferences(e.begin,{joinWith:""})}}
/**
 * @param {CompiledMode} mode
 */function endMultiClass(e){if(Array.isArray(e.end)){if(e.skip||e.excludeEnd||e.returnEnd){error("skip, excludeEnd, returnEnd not compatible with endScope: {}");throw L}if("object"!==typeof e.endScope||null===e.endScope){error("endScope must be object");throw L}remapScopeNames(e,e.end,{key:"endScope"});e.end=_rewriteBackreferences(e.end,{joinWith:""})}}
/**
 * this exists only to allow `scope: {}` to be used beside `match:`
 * Otherwise `beginScope` would necessary and that would look weird

  {
    match: [ /def/, /\w+/ ]
    scope: { 1: "keyword" , 2: "title" }
  }

 * @param {CompiledMode} mode
 */function scopeSugar(e){if(e.scope&&"object"===typeof e.scope&&null!==e.scope){e.beginScope=e.scope;delete e.scope}}
/**
 * @param {CompiledMode} mode
 */function MultiClass(e){scopeSugar(e);"string"===typeof e.beginScope&&(e.beginScope={_wrap:e.beginScope});"string"===typeof e.endScope&&(e.endScope={_wrap:e.endScope});beginMultiClass(e);endMultiClass(e)}
/**
@typedef {import('highlight.js').Mode} Mode
@typedef {import('highlight.js').CompiledMode} CompiledMode
@typedef {import('highlight.js').Language} Language
@typedef {import('highlight.js').HLJSPlugin} HLJSPlugin
@typedef {import('highlight.js').CompiledLanguage} CompiledLanguage
*/
/**
 * Compiles a language definition result
 *
 * Given the raw result of a language definition (Language), compiles this so
 * that it is ready for highlighting code.
 * @param {Language} language
 * @returns {CompiledLanguage}
 */function compileLanguage(e){
/**
   * Builds a regex with the case sensitivity of the current language
   *
   * @param {RegExp | string} value
   * @param {boolean} [global]
   */
function langRe(t,n){return new RegExp(source(t),"m"+(e.case_insensitive?"i":"")+(e.unicodeRegex?"u":"")+(n?"g":""))}class MultiRegex{constructor(){this.matchIndexes={};this.regexes=[];this.matchAt=1;this.position=0}addRule(e,t){t.position=this.position++;this.matchIndexes[this.matchAt]=t;this.regexes.push([t,e]);this.matchAt+=countMatchGroups(e)+1}compile(){0===this.regexes.length&&(this.exec=()=>null);const e=this.regexes.map((e=>e[1]));this.matcherRe=langRe(_rewriteBackreferences(e,{joinWith:"|"}),true);this.lastIndex=0}
/** @param {string} s */exec(e){this.matcherRe.lastIndex=this.lastIndex;const t=this.matcherRe.exec(e);if(!t)return null;const n=t.findIndex(((e,t)=>t>0&&void 0!==e));const i=this.matchIndexes[n];t.splice(0,n);return Object.assign(t,i)}}class ResumableMultiRegex{constructor(){this.rules=[];this.multiRegexes=[];this.count=0;this.lastIndex=0;this.regexIndex=0}getMatcher(e){if(this.multiRegexes[e])return this.multiRegexes[e];const t=new MultiRegex;this.rules.slice(e).forEach((([e,n])=>t.addRule(e,n)));t.compile();this.multiRegexes[e]=t;return t}resumingScanAtSamePosition(){return 0!==this.regexIndex}considerAll(){this.regexIndex=0}addRule(e,t){this.rules.push([e,t]);"begin"===t.type&&this.count++}
/** @param {string} s */exec(e){const t=this.getMatcher(this.regexIndex);t.lastIndex=this.lastIndex;let n=t.exec(e);if(this.resumingScanAtSamePosition())if(n&&n.index===this.lastIndex);else{const t=this.getMatcher(0);t.lastIndex=this.lastIndex+1;n=t.exec(e)}if(n){this.regexIndex+=n.position+1;this.regexIndex===this.count&&this.considerAll()}return n}}
/**
   * Given a mode, builds a huge ResumableMultiRegex that can be used to walk
   * the content and find matches.
   *
   * @param {CompiledMode} mode
   * @returns {ResumableMultiRegex}
   */function buildModeRegex(e){const t=new ResumableMultiRegex;e.contains.forEach((e=>t.addRule(e.begin,{rule:e,type:"begin"})));e.terminatorEnd&&t.addRule(e.terminatorEnd,{type:"end"});e.illegal&&t.addRule(e.illegal,{type:"illegal"});return t}
/**
   * Compiles an individual mode
   *
   * This can raise an error if the mode contains certain detectable known logic
   * issues.
   * @param {Mode} mode
   * @param {CompiledMode | null} [parent]
   * @returns {CompiledMode | never}
   */function compileMode(t,n){const i=/** @type CompiledMode */t;if(t.isCompiled)return i;[scopeClassName,compileMatch,MultiClass,beforeMatchExt].forEach((e=>e(t,n)));e.compilerExtensions.forEach((e=>e(t,n)));t.__beforeBegin=null;[beginKeywords,compileIllegal,compileRelevance].forEach((e=>e(t,n)));t.isCompiled=true;let o=null;if("object"===typeof t.keywords&&t.keywords.$pattern){t.keywords=Object.assign({},t.keywords);o=t.keywords.$pattern;delete t.keywords.$pattern}o=o||/\w+/;t.keywords&&(t.keywords=compileKeywords(t.keywords,e.case_insensitive));i.keywordPatternRe=langRe(o,true);if(n){t.begin||(t.begin=/\B|\b/);i.beginRe=langRe(i.begin);t.end||t.endsWithParent||(t.end=/\B|\b/);t.end&&(i.endRe=langRe(i.end));i.terminatorEnd=source(i.end)||"";t.endsWithParent&&n.terminatorEnd&&(i.terminatorEnd+=(t.end?"|":"")+n.terminatorEnd)}t.illegal&&(i.illegalRe=langRe(/** @type {RegExp | string} */t.illegal));t.contains||(t.contains=[]);t.contains=[].concat(...t.contains.map((function(e){return expandOrCloneMode("self"===e?t:e)})));t.contains.forEach((function(e){compileMode(/** @type Mode */e,i)}));t.starts&&compileMode(t.starts,n);i.matcher=buildModeRegex(i);return i}e.compilerExtensions||(e.compilerExtensions=[]);if(e.contains&&e.contains.includes("self"))throw new Error("ERR: contains `self` is not supported at the top-level of a language.  See documentation.");e.classNameAliases=inherit$1(e.classNameAliases||{});return compileMode(/** @type Mode */e)}
/**
 * Determines if a mode has a dependency on it's parent or not
 *
 * If a mode does have a parent dependency then often we need to clone it if
 * it's used in multiple places so that each copy points to the correct parent,
 * where-as modes without a parent can often safely be re-used at the bottom of
 * a mode chain.
 *
 * @param {Mode | null} mode
 * @returns {boolean} - is there a dependency on the parent?
 * */function dependencyOnParent(e){return!!e&&(e.endsWithParent||dependencyOnParent(e.starts))}
/**
 * Expands a mode or clones it if necessary
 *
 * This is necessary for modes with parental dependenceis (see notes on
 * `dependencyOnParent`) and for nodes that have `variants` - which must then be
 * exploded into their own individual modes at compile time.
 *
 * @param {Mode} mode
 * @returns {Mode | Mode[]}
 * */function expandOrCloneMode(e){e.variants&&!e.cachedVariants&&(e.cachedVariants=e.variants.map((function(t){return inherit$1(e,{variants:null},t)})));return e.cachedVariants?e.cachedVariants:dependencyOnParent(e)?inherit$1(e,{starts:e.starts?inherit$1(e.starts):null}):Object.isFrozen(e)?inherit$1(e):e}var S="11.9.0";class HTMLInjectionError extends Error{constructor(e,t){super(e);this.name="HTMLInjectionError";this.html=t}}
/**
@typedef {import('highlight.js').Mode} Mode
@typedef {import('highlight.js').CompiledMode} CompiledMode
@typedef {import('highlight.js').CompiledScope} CompiledScope
@typedef {import('highlight.js').Language} Language
@typedef {import('highlight.js').HLJSApi} HLJSApi
@typedef {import('highlight.js').HLJSPlugin} HLJSPlugin
@typedef {import('highlight.js').PluginEvent} PluginEvent
@typedef {import('highlight.js').HLJSOptions} HLJSOptions
@typedef {import('highlight.js').LanguageFn} LanguageFn
@typedef {import('highlight.js').HighlightedHTMLElement} HighlightedHTMLElement
@typedef {import('highlight.js').BeforeHighlightContext} BeforeHighlightContext
@typedef {import('highlight.js/private').MatchType} MatchType
@typedef {import('highlight.js/private').KeywordData} KeywordData
@typedef {import('highlight.js/private').EnhancedMatch} EnhancedMatch
@typedef {import('highlight.js/private').AnnotatedError} AnnotatedError
@typedef {import('highlight.js').AutoHighlightResult} AutoHighlightResult
@typedef {import('highlight.js').HighlightOptions} HighlightOptions
@typedef {import('highlight.js').HighlightResult} HighlightResult
*/const A=escapeHTML;const T=inherit$1;const v=Symbol("nomatch");const I=7;
/**
 * @param {any} hljs - object that is extended (legacy)
 * @returns {HLJSApi}
 */const HLJS=function(e){
/** @type {Record<string, Language>} */
const t=Object.create(null);
/** @type {Record<string, string>} */const n=Object.create(null);
/** @type {HLJSPlugin[]} */const i=[];let o=true;const s="Could not find the language '{}', did you forget to load/include a language module?";
/** @type {Language} */const r={disableAutodetect:true,name:"Plain text",contains:[]};
/** @type HLJSOptions */let a={ignoreUnescapedHTML:false,throwUnescapedHTML:false,noHighlightRe:/^(no-?highlight)$/i,languageDetectRe:/\blang(?:uage)?-([\w-]+)\b/i,classPrefix:"hljs-",cssSelector:"pre code",languages:null,__emitter:TokenTreeEmitter};
/**
   * Tests a language name to see if highlighting should be skipped
   * @param {string} languageName
   */function shouldNotHighlight(e){return a.noHighlightRe.test(e)}
/**
   * @param {HighlightedHTMLElement} block - the HTML element to determine language for
   */function blockLanguage(e){let t=e.className+" ";t+=e.parentNode?e.parentNode.className:"";const n=a.languageDetectRe.exec(t);if(n){const t=getLanguage(n[1]);if(!t){warn(s.replace("{}",n[1]));warn("Falling back to no-highlight mode for this block.",e)}return t?n[1]:"no-highlight"}return t.split(/\s+/).find((e=>shouldNotHighlight(e)||getLanguage(e)))}
/**
   * Core highlighting function.
   *
   * OLD API
   * highlight(lang, code, ignoreIllegals, continuation)
   *
   * NEW API
   * highlight(code, {lang, ignoreIllegals})
   *
   * @param {string} codeOrLanguageName - the language to use for highlighting
   * @param {string | HighlightOptions} optionsOrCode - the code to highlight
   * @param {boolean} [ignoreIllegals] - whether to ignore illegal matches, default is to bail
   *
   * @returns {HighlightResult} Result - an object that represents the result
   * @property {string} language - the language name
   * @property {number} relevance - the relevance score
   * @property {string} value - the highlighted HTML code
   * @property {string} code - the original raw code
   * @property {CompiledMode} top - top of the current mode stack
   * @property {boolean} illegal - indicates whether any illegal matches were found
  */function highlight(e,t,n){let i="";let o="";if("object"===typeof t){i=e;n=t.ignoreIllegals;o=t.language}else{deprecated("10.7.0","highlight(lang, code, ...args) has been deprecated.");deprecated("10.7.0","Please use highlight(code, options) instead.\nhttps://github.com/highlightjs/highlight.js/issues/2277");o=e;i=t}void 0===n&&(n=true)
/** @type {BeforeHighlightContext} */;const s={code:i,language:o};fire("before:highlight",s);const r=s.result?s.result:_highlight(s.language,s.code,n);r.code=s.code;fire("after:highlight",r);return r}
/**
   * private highlight that's used internally and does not fire callbacks
   *
   * @param {string} languageName - the language to use for highlighting
   * @param {string} codeToHighlight - the code to highlight
   * @param {boolean?} [ignoreIllegals] - whether to ignore illegal matches, default is to bail
   * @param {CompiledMode?} [continuation] - current continuation mode, if any
   * @returns {HighlightResult} - result of the highlight operation
  */function _highlight(e,n,i,r){const c=Object.create(null);
/**
     * Return keyword data if a match is a keyword
     * @param {CompiledMode} mode - current mode
     * @param {string} matchText - the textual match
     * @returns {KeywordData | false}
     */function keywordData(e,t){return e.keywords[t]}function processKeywords(){if(!d.keywords){p.addText(m);return}let e=0;d.keywordPatternRe.lastIndex=0;let t=d.keywordPatternRe.exec(m);let n="";while(t){n+=m.substring(e,t.index);const i=g.case_insensitive?t[0].toLowerCase():t[0];const o=keywordData(d,i);if(o){const[e,s]=o;p.addText(n);n="";c[i]=(c[i]||0)+1;c[i]<=I&&(b+=s);if(e.startsWith("_"))n+=t[0];else{const n=g.classNameAliases[e]||e;emitKeyword(t[0],n)}}else n+=t[0];e=d.keywordPatternRe.lastIndex;t=d.keywordPatternRe.exec(m)}n+=m.substring(e);p.addText(n)}function processSubLanguage(){if(""===m)return;
/** @type HighlightResult */let e=null;if("string"===typeof d.subLanguage){if(!t[d.subLanguage]){p.addText(m);return}e=_highlight(d.subLanguage,m,true,f[d.subLanguage]);f[d.subLanguage]=/** @type {CompiledMode} */e._top}else e=highlightAuto(m,d.subLanguage.length?d.subLanguage:null);d.relevance>0&&(b+=e.relevance);p.__addSublanguage(e._emitter,e.language)}function processBuffer(){null!=d.subLanguage?processSubLanguage():processKeywords();m=""}
/**
     * @param {string} text
     * @param {string} scope
     */function emitKeyword(e,t){if(""!==e){p.startScope(t);p.addText(e);p.endScope()}}
/**
     * @param {CompiledScope} scope
     * @param {RegExpMatchArray} match
     */function emitMultiClass(e,t){let n=1;const i=t.length-1;while(n<=i){if(!e._emit[n]){n++;continue}const i=g.classNameAliases[e[n]]||e[n];const o=t[n];if(i)emitKeyword(o,i);else{m=o;processKeywords();m=""}n++}}
/**
     * @param {CompiledMode} mode - new mode to start
     * @param {RegExpMatchArray} match
     */function startNewMode(e,t){e.scope&&"string"===typeof e.scope&&p.openNode(g.classNameAliases[e.scope]||e.scope);if(e.beginScope)if(e.beginScope._wrap){emitKeyword(m,g.classNameAliases[e.beginScope._wrap]||e.beginScope._wrap);m=""}else if(e.beginScope._multi){emitMultiClass(e.beginScope,t);m=""}d=Object.create(e,{parent:{value:d}});return d}
/**
     * @param {CompiledMode } mode - the mode to potentially end
     * @param {RegExpMatchArray} match - the latest match
     * @param {string} matchPlusRemainder - match plus remainder of content
     * @returns {CompiledMode | void} - the next mode, or if void continue on in current mode
     */function endOfMode(e,t,n){let i=startsWith(e.endRe,n);if(i){if(e["on:end"]){const n=new Response(e);e["on:end"](t,n);n.isMatchIgnored&&(i=false)}if(i){while(e.endsParent&&e.parent)e=e.parent;return e}}if(e.endsWithParent)return endOfMode(e.parent,t,n)}
/**
     * Handle matching but then ignoring a sequence of text
     *
     * @param {string} lexeme - string containing full match text
     */function doIgnore(e){if(0===d.matcher.regexIndex){m+=e[0];return 1}x=true;return 0}
/**
     * Handle the start of a new potential mode match
     *
     * @param {EnhancedMatch} match - the current match
     * @returns {number} how far to advance the parse cursor
     */function doBeginMatch(e){const t=e[0];const n=e.rule;const i=new Response(n);const o=[n.__beforeBegin,n["on:begin"]];for(const n of o)if(n){n(e,i);if(i.isMatchIgnored)return doIgnore(t)}if(n.skip)m+=t;else{n.excludeBegin&&(m+=t);processBuffer();n.returnBegin||n.excludeBegin||(m=t)}startNewMode(n,e);return n.returnBegin?0:t.length}
/**
     * Handle the potential end of mode
     *
     * @param {RegExpMatchArray} match - the current match
     */function doEndMatch(e){const t=e[0];const i=n.substring(e.index);const o=endOfMode(d,e,i);if(!o)return v;const s=d;if(d.endScope&&d.endScope._wrap){processBuffer();emitKeyword(t,d.endScope._wrap)}else if(d.endScope&&d.endScope._multi){processBuffer();emitMultiClass(d.endScope,e)}else if(s.skip)m+=t;else{s.returnEnd||s.excludeEnd||(m+=t);processBuffer();s.excludeEnd&&(m=t)}do{d.scope&&p.closeNode();d.skip||d.subLanguage||(b+=d.relevance);d=d.parent}while(d!==o.parent);o.starts&&startNewMode(o.starts,e);return s.returnEnd?0:t.length}function processContinuations(){const e=[];for(let t=d;t!==g;t=t.parent)t.scope&&e.unshift(t.scope);e.forEach((e=>p.openNode(e)))}
/** @type {{type?: MatchType, index?: number, rule?: Mode}}} */let l={};
/**
     *  Process an individual match
     *
     * @param {string} textBeforeMatch - text preceding the match (since the last match)
     * @param {EnhancedMatch} [match] - the match itself
     */function processLexeme(t,s){const r=s&&s[0];m+=t;if(null==r){processBuffer();return 0}if("begin"===l.type&&"end"===s.type&&l.index===s.index&&""===r){m+=n.slice(s.index,s.index+1);if(!o){
/** @type {AnnotatedError} */
const t=new Error(`0 width match regex (${e})`);t.languageName=e;t.badRule=l.rule;throw t}return 1}l=s;if("begin"===s.type)return doBeginMatch(s);if("illegal"===s.type&&!i){
/** @type {AnnotatedError} */
const e=new Error('Illegal lexeme "'+r+'" for mode "'+(d.scope||"<unnamed>")+'"');e.mode=d;throw e}if("end"===s.type){const e=doEndMatch(s);if(e!==v)return e}if("illegal"===s.type&&""===r)return 1;if(E>1e5&&E>3*s.index){const e=new Error("potential infinite loop, way more iterations than matches");throw e}m+=r;return r.length}const g=getLanguage(e);if(!g){error(s.replace("{}",e));throw new Error('Unknown language: "'+e+'"')}const u=compileLanguage(g);let h="";
/** @type {CompiledMode} */let d=r||u;
/** @type Record<string,CompiledMode> */const f={};const p=new a.__emitter(a);processContinuations();let m="";let b=0;let w=0;let E=0;let x=false;try{if(g.__emitTokens)g.__emitTokens(n,p);else{d.matcher.considerAll();for(;;){E++;x?x=false:d.matcher.considerAll();d.matcher.lastIndex=w;const e=d.matcher.exec(n);if(!e)break;const t=n.substring(w,e.index);const i=processLexeme(t,e);w=e.index+i}processLexeme(n.substring(w))}p.finalize();h=p.toHTML();return{language:e,value:h,relevance:b,illegal:false,_emitter:p,_top:d}}catch(t){if(t.message&&t.message.includes("Illegal"))return{language:e,value:A(n),illegal:true,relevance:0,_illegalBy:{message:t.message,index:w,context:n.slice(w-100,w+100),mode:t.mode,resultSoFar:h},_emitter:p};if(o)return{language:e,value:A(n),illegal:false,relevance:0,errorRaised:t,_emitter:p,_top:d};throw t}}
/**
   * returns a valid highlight result, without actually doing any actual work,
   * auto highlight starts with this and it's possible for small snippets that
   * auto-detection may not find a better match
   * @param {string} code
   * @returns {HighlightResult}
   */function justTextHighlightResult(e){const t={value:A(e),illegal:false,relevance:0,_top:r,_emitter:new a.__emitter(a)};t._emitter.addText(e);return t}
/**
  Highlighting with language detection. Accepts a string with the code to
  highlight. Returns an object with the following properties:
   - language (detected language)
  - relevance (int)
  - value (an HTML string with highlighting markup)
  - secondBest (object with the same structure for second-best heuristically
    detected language, may be absent)
     @param {string} code
    @param {Array<string>} [languageSubset]
    @returns {AutoHighlightResult}
  */function highlightAuto(e,n){n=n||a.languages||Object.keys(t);const i=justTextHighlightResult(e);const o=n.filter(getLanguage).filter(autoDetection).map((t=>_highlight(t,e,false)));o.unshift(i);const s=o.sort(((e,t)=>{if(e.relevance!==t.relevance)return t.relevance-e.relevance;if(e.language&&t.language){if(getLanguage(e.language).supersetOf===t.language)return 1;if(getLanguage(t.language).supersetOf===e.language)return-1}return 0}));const[r,c]=s;
/** @type {AutoHighlightResult} */const l=r;l.secondBest=c;return l}
/**
   * Builds new class name for block given the language name
   *
   * @param {HTMLElement} element
   * @param {string} [currentLang]
   * @param {string} [resultLang]
   */function updateClassName(e,t,i){const o=t&&n[t]||i;e.classList.add("hljs");e.classList.add(`language-${o}`)}
/**
   * Applies highlighting to a DOM node containing code.
   *
   * @param {HighlightedHTMLElement} element - the HTML element to highlight
  */function highlightElement(e){
/** @type HTMLElement */
let t=null;const n=blockLanguage(e);if(shouldNotHighlight(n))return;fire("before:highlightElement",{el:e,language:n});if(e.dataset.highlighted){console.log("Element previously highlighted. To highlight again, first unset `dataset.highlighted`.",e);return}if(e.children.length>0){if(!a.ignoreUnescapedHTML){console.warn("One of your code blocks includes unescaped HTML. This is a potentially serious security risk.");console.warn("https://github.com/highlightjs/highlight.js/wiki/security");console.warn("The element with unescaped HTML:");console.warn(e)}if(a.throwUnescapedHTML){const t=new HTMLInjectionError("One of your code blocks includes unescaped HTML.",e.innerHTML);throw t}}t=e;const i=t.textContent;const o=n?highlight(i,{language:n,ignoreIllegals:true}):highlightAuto(i);e.innerHTML=o.value;e.dataset.highlighted="yes";updateClassName(e,n,o.language);e.result={language:o.language,re:o.relevance,relevance:o.relevance};o.secondBest&&(e.secondBest={language:o.secondBest.language,relevance:o.secondBest.relevance});fire("after:highlightElement",{el:e,result:o,text:i})}
/**
   * Updates highlight.js global options with the passed options
   *
   * @param {Partial<HLJSOptions>} userOptions
   */function configure(e){a=T(a,e)}const initHighlighting=()=>{highlightAll();deprecated("10.6.0","initHighlighting() deprecated.  Use highlightAll() now.")};function initHighlightingOnLoad(){highlightAll();deprecated("10.6.0","initHighlightingOnLoad() deprecated.  Use highlightAll() now.")}let c=false;function highlightAll(){if("loading"===document.readyState){c=true;return}const e=document.querySelectorAll(a.cssSelector);e.forEach(highlightElement)}function boot(){c&&highlightAll()}"undefined"!==typeof window&&window.addEventListener&&window.addEventListener("DOMContentLoaded",boot,false)
/**
   * Register a language grammar module
   *
   * @param {string} languageName
   * @param {LanguageFn} languageDefinition
   */;function registerLanguage(n,i){let s=null;try{s=i(e)}catch(e){error("Language definition for '{}' could not be registered.".replace("{}",n));if(!o)throw e;error(e);s=r}s.name||(s.name=n);t[n]=s;s.rawDefinition=i.bind(null,e);s.aliases&&registerAliases(s.aliases,{languageName:n})}
/**
   * Remove a language grammar module
   *
   * @param {string} languageName
   */function unregisterLanguage(e){delete t[e];for(const t of Object.keys(n))n[t]===e&&delete n[t]}
/**
   * @returns {string[]} List of language internal names
   */function listLanguages(){return Object.keys(t)}
/**
   * @param {string} name - name of the language to retrieve
   * @returns {Language | undefined}
   */function getLanguage(e){e=(e||"").toLowerCase();return t[e]||t[n[e]]}
/**
   *
   * @param {string|string[]} aliasList - single alias or list of aliases
   * @param {{languageName: string}} opts
   */function registerAliases(e,{languageName:t}){"string"===typeof e&&(e=[e]);e.forEach((e=>{n[e.toLowerCase()]=t}))}
/**
   * Determines if a given language has auto-detection enabled
   * @param {string} name - name of the language
   */function autoDetection(e){const t=getLanguage(e);return t&&!t.disableAutodetect}
/**
   * Upgrades the old highlightBlock plugins to the new
   * highlightElement API
   * @param {HLJSPlugin} plugin
   */function upgradePluginAPI(e){e["before:highlightBlock"]&&!e["before:highlightElement"]&&(e["before:highlightElement"]=t=>{e["before:highlightBlock"](Object.assign({block:t.el},t))});e["after:highlightBlock"]&&!e["after:highlightElement"]&&(e["after:highlightElement"]=t=>{e["after:highlightBlock"](Object.assign({block:t.el},t))})}
/**
   * @param {HLJSPlugin} plugin
   */function addPlugin(e){upgradePluginAPI(e);i.push(e)}
/**
   * @param {HLJSPlugin} plugin
   */function removePlugin(e){const t=i.indexOf(e);-1!==t&&i.splice(t,1)}
/**
   *
   * @param {PluginEvent} event
   * @param {any} args
   */function fire(e,t){const n=e;i.forEach((function(e){e[n]&&e[n](t)}))}
/**
   * DEPRECATED
   * @param {HighlightedHTMLElement} el
   */function deprecateHighlightBlock(e){deprecated("10.7.0","highlightBlock will be removed entirely in v12.0");deprecated("10.7.0","Please use highlightElement now.");return highlightElement(e)}Object.assign(e,{highlight:highlight,highlightAuto:highlightAuto,highlightAll:highlightAll,highlightElement:highlightElement,highlightBlock:deprecateHighlightBlock,configure:configure,initHighlighting:initHighlighting,initHighlightingOnLoad:initHighlightingOnLoad,registerLanguage:registerLanguage,unregisterLanguage:unregisterLanguage,listLanguages:listLanguages,getLanguage:getLanguage,registerAliases:registerAliases,autoDetection:autoDetection,inherit:T,addPlugin:addPlugin,removePlugin:removePlugin});e.debugMode=function(){o=false};e.safeMode=function(){o=true};e.versionString=S;e.regex={concat:concat,lookahead:lookahead,either:either,optional:optional,anyNumberOfTimes:anyNumberOfTimes};for(const e in k)"object"===typeof k[e]&&deepFreeze(k[e]);Object.assign(e,k);return e};const j=HLJS({});j.newInstance=()=>HLJS({});e=j;j.HighlightJS=j;j.default=j;var B=e;export{B as default};

//# sourceMappingURL=core.js.map
