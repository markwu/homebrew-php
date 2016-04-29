require 'formula'

class BetterphpCtags < Formula
  desc "Original Ctags with Better PHP Parser"
  homepage "http://ctags.sourceforge.net/"
  url "https://downloads.sourceforge.net/ctags/ctags-5.8.tar.gz"
  sha256 "0e44b45dcabe969e0bbbb11e30c246f81abe5d32012db37395eb57d66e9e99c7"
  version "5.8"

  patch :p2, :DATA

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-macro-patterns",
                          "--mandir=#{man}",
                          "--with-readlib"
    system "make", "install"
  end

  def caveats
    <<-EOS.undent
      Under some circumstances, emacs and ctags can conflict. By default,
      emacs provides an executable `ctags` that would conflict with the
      executable of the same name that ctags provides. To prevent this,
      Homebrew removes the emacs `ctags` and its manpage before linking.

      However, if you install emacs with the `--keep-ctags` option, then
      the `ctags` emacs provides will not be removed. In that case, you
      won't be able to install ctags successfully. It will build but not
      link.
    EOS
  end
end

__END__

diff -ur a/ctags-5.8/read.c b/ctags-5.8/read.c
--- a/ctags-5.8/read.c	2009-07-04 17:29:02.000000000 +1200
+++ b/ctags-5.8/read.c	2012-11-04 16:19:27.000000000 +1300
@@ -18,7 +18,6 @@
 #include <string.h>
 #include <ctype.h>
 
-#define FILE_WRITE
 #include "read.h"
 #include "debug.h"
 #include "entry.h"

diff -ur a/ctags-5.8/read.h b/ctags-5.8/read.h
--- a/ctags-5.8/read.h	2008-04-30 13:45:57.000000000 +1200
+++ b/ctags-5.8/read.h	2012-11-04 16:19:18.000000000 +1300
@@ -11,12 +11,6 @@
 #ifndef _READ_H
 #define _READ_H
 
-#if defined(FILE_WRITE) || defined(VAXC)
-# define CONST_FILE
-#else
-# define CONST_FILE const
-#endif
-
 /*
 *   INCLUDE FILES
 */
@@ -95,7 +89,7 @@
 /*
 *   GLOBAL VARIABLES
 */
-extern CONST_FILE inputFile File;
+extern inputFile File;
 
 /*
 *   FUNCTION PROTOTYPES

diff -ur a/ctags-5.8/routines.c b/ctags-5.8/routines.c
--- a/ctags-5.8/routines.c	2007-06-07 00:35:21.000000000 -0400
+++ b/ctags-5.8/routines.c	2015-03-07 20:38:58.000000000 -0500
@@ -757,13 +757,13 @@
 				else if (cp [0] != PATH_SEPARATOR)
 					cp = slashp;
 #endif
-				strcpy (cp, slashp + 3);
+				memmove (cp, slashp + 3, strlen (slashp + 3) + 1);
 				slashp = cp;
 				continue;
 			}
 			else if (slashp [2] == PATH_SEPARATOR  ||  slashp [2] == '\0')
 			{
-				strcpy (slashp, slashp + 2);
+				memmove (slashp, slashp + 2, strlen (slashp + 2) + 1);
 				continue;
 			}
 		}

diff --ur a/ctags-5.8/php.c b/ctags-5.8/php.c
--- a/ctags-5.8/php.c	2007-12-29 00:40:08.000000000 +0800
+++ b/ctags-5.8/php.c	2016-04-27 18:06:25.000000000 +0800
@@ -1,237 +1,1468 @@
 /*
-*   $Id: php.c 624 2007-09-15 22:53:31Z jafl $
+*   $Id$
 *
-*   Copyright (c) 2000, Jesus Castagnetto <jmcastagnetto@zkey.com>
+*   Copyright (c) 2013, Colomban Wendling <ban@herbesfolles.org>
 *
 *   This source code is released for free distribution under the terms of the
 *   GNU General Public License.
 *
-*   This module contains functions for generating tags for the PHP web page
-*   scripting language. Only recognizes functions and classes, not methods or
-*   variables.
-*
-*   Parsing PHP defines by Pavel Hlousek <pavel.hlousek@seznam.cz>, Apr 2003.
+*   This module contains code for generating tags for the PHP scripting
+*   language.
 */
 
 /*
 *   INCLUDE FILES
 */
 #include "general.h"  /* must always come first */
-
-#include <string.h>
-
 #include "parse.h"
 #include "read.h"
 #include "vstring.h"
+#include "keyword.h"
+#include "entry.h"
+#include "routines.h"
+#include "debug.h"
+
+
+#define SCOPE_SEPARATOR "::"
+
+
+typedef enum {
+	KEYWORD_NONE = -1,
+	KEYWORD_abstract,
+	KEYWORD_and,
+	KEYWORD_as,
+	KEYWORD_break,
+	KEYWORD_callable,
+	KEYWORD_case,
+	KEYWORD_catch,
+	KEYWORD_class,
+	KEYWORD_clone,
+	KEYWORD_const,
+	KEYWORD_continue,
+	KEYWORD_declare,
+	KEYWORD_define,
+	KEYWORD_default,
+	KEYWORD_do,
+	KEYWORD_echo,
+	KEYWORD_else,
+	KEYWORD_elif,
+	KEYWORD_enddeclare,
+	KEYWORD_endfor,
+	KEYWORD_endforeach,
+	KEYWORD_endif,
+	KEYWORD_endswitch,
+	KEYWORD_endwhile,
+	KEYWORD_extends,
+	KEYWORD_final,
+	KEYWORD_finally,
+	KEYWORD_for,
+	KEYWORD_foreach,
+	KEYWORD_function,
+	KEYWORD_global,
+	KEYWORD_goto,
+	KEYWORD_if,
+	KEYWORD_implements,
+	KEYWORD_include,
+	KEYWORD_include_once,
+	KEYWORD_instanceof,
+	KEYWORD_insteadof,
+	KEYWORD_interface,
+	KEYWORD_namespace,
+	KEYWORD_new,
+	KEYWORD_or,
+	KEYWORD_print,
+	KEYWORD_private,
+	KEYWORD_protected,
+	KEYWORD_public,
+	KEYWORD_require,
+	KEYWORD_require_once,
+	KEYWORD_return,
+	KEYWORD_static,
+	KEYWORD_switch,
+	KEYWORD_throw,
+	KEYWORD_trait,
+	KEYWORD_try,
+	KEYWORD_use,
+	KEYWORD_var,
+	KEYWORD_while,
+	KEYWORD_xor,
+	KEYWORD_yield
+} keywordId;
+
+typedef enum {
+	ACCESS_UNDEFINED,
+	ACCESS_PRIVATE,
+	ACCESS_PROTECTED,
+	ACCESS_PUBLIC,
+	COUNT_ACCESS
+} accessType;
+
+typedef enum {
+	IMPL_UNDEFINED,
+	IMPL_ABSTRACT,
+	COUNT_IMPL
+} implType;
 
-/*
-*   DATA DEFINITIONS
-*/
 typedef enum {
-	K_CLASS, K_DEFINE, K_FUNCTION, K_VARIABLE
+	K_CLASS,
+	K_DEFINE,
+	K_FUNCTION,
+	K_INTERFACE,
+	K_LOCAL_VARIABLE,
+	K_NAMESPACE,
+	K_TRAIT,
+	K_VARIABLE,
+	COUNT_KIND
 } phpKind;
 
-#if 0
-static kindOption PhpKinds [] = {
-	{ TRUE, 'c', "class",    "classes" },
-	{ TRUE, 'd', "define",   "constant definitions" },
-	{ TRUE, 'f', "function", "functions" },
-	{ TRUE, 'v', "variable", "variables" }
+static kindOption PhpKinds[COUNT_KIND] = {
+	{ TRUE, 'c', "class",		"classes" },
+	{ TRUE, 'd', "define",		"constant definitions" },
+	{ TRUE, 'f', "function",	"functions" },
+	{ TRUE, 'i', "interface",	"interfaces" },
+	{ FALSE, 'l', "local",		"local variables" },
+	{ TRUE, 'n', "namespace",	"namespaces" },
+	{ TRUE, 't', "trait",		"traits" },
+	{ TRUE, 'v', "variable",	"variables" }
 };
-#endif
 
-/*
-*   FUNCTION DEFINITIONS
-*/
+typedef struct {
+	const char *name;
+	keywordId id;
+} keywordDesc;
+
+static const keywordDesc PhpKeywordTable[] = {
+	/* keyword			keyword ID */
+	{ "abstract",		KEYWORD_abstract		},
+	{ "and",			KEYWORD_and				},
+	{ "as",				KEYWORD_as				},
+	{ "break",			KEYWORD_break			},
+	{ "callable",		KEYWORD_callable		},
+	{ "case",			KEYWORD_case			},
+	{ "catch",			KEYWORD_catch			},
+	{ "cfunction",		KEYWORD_function		}, /* nobody knows what the hell this is, but it seems to behave much like "function" so bind it to it */
+	{ "class",			KEYWORD_class			},
+	{ "clone",			KEYWORD_clone			},
+	{ "const",			KEYWORD_const			},
+	{ "continue",		KEYWORD_continue		},
+	{ "declare",		KEYWORD_declare			},
+	{ "define",			KEYWORD_define			}, /* this isn't really a keyword but we handle it so it's easier this way */
+	{ "default",		KEYWORD_default			},
+	{ "do",				KEYWORD_do				},
+	{ "echo",			KEYWORD_echo			},
+	{ "else",			KEYWORD_else			},
+	{ "elseif",			KEYWORD_elif			},
+	{ "enddeclare",		KEYWORD_enddeclare		},
+	{ "endfor",			KEYWORD_endfor			},
+	{ "endforeach",		KEYWORD_endforeach		},
+	{ "endif",			KEYWORD_endif			},
+	{ "endswitch",		KEYWORD_endswitch		},
+	{ "endwhile",		KEYWORD_endwhile		},
+	{ "extends",		KEYWORD_extends			},
+	{ "final",			KEYWORD_final			},
+	{ "finally",		KEYWORD_finally			},
+	{ "for",			KEYWORD_for				},
+	{ "foreach",		KEYWORD_foreach			},
+	{ "function",		KEYWORD_function		},
+	{ "global",			KEYWORD_global			},
+	{ "goto",			KEYWORD_goto			},
+	{ "if",				KEYWORD_if				},
+	{ "implements",		KEYWORD_implements		},
+	{ "include",		KEYWORD_include			},
+	{ "include_once",	KEYWORD_include_once	},
+	{ "instanceof",		KEYWORD_instanceof		},
+	{ "insteadof",		KEYWORD_insteadof		},
+	{ "interface",		KEYWORD_interface		},
+	{ "namespace",		KEYWORD_namespace		},
+	{ "new",			KEYWORD_new				},
+	{ "or",				KEYWORD_or				},
+	{ "print",			KEYWORD_print			},
+	{ "private",		KEYWORD_private			},
+	{ "protected",		KEYWORD_protected		},
+	{ "public",			KEYWORD_public			},
+	{ "require",		KEYWORD_require			},
+	{ "require_once",	KEYWORD_require_once	},
+	{ "return",			KEYWORD_return			},
+	{ "static",			KEYWORD_static			},
+	{ "switch",			KEYWORD_switch			},
+	{ "throw",			KEYWORD_throw			},
+	{ "trait",			KEYWORD_trait			},
+	{ "try",			KEYWORD_try				},
+	{ "use",			KEYWORD_use				},
+	{ "var",			KEYWORD_var				},
+	{ "while",			KEYWORD_while			},
+	{ "xor",			KEYWORD_xor				},
+	{ "yield",			KEYWORD_yield			}
+};
 
-/* JavaScript patterns are duplicated in jscript.c */
 
-/*
- * Cygwin doesn't support non-ASCII characters in character classes.
- * This isn't a good solution to the underlying problem, because we're still
- * making assumptions about the character encoding.
- * Really, these regular expressions need to concentrate on what marks the
- * end of an identifier, and we need something like iconv to take into
- * account the user's locale (or an override on the command-line.)
- */
-#ifdef __CYGWIN__
-#define ALPHA "[:alpha:]"
-#define ALNUM "[:alnum:]"
-#else
-#define ALPHA "A-Za-z\x7f-\xff"
-#define ALNUM "0-9A-Za-z\x7f-\xff"
-#endif
+typedef enum eTokenType {
+	TOKEN_UNDEFINED,
+	TOKEN_EOF,
+	TOKEN_CHARACTER,
+	TOKEN_CLOSE_PAREN,
+	TOKEN_SEMICOLON,
+	TOKEN_COLON,
+	TOKEN_COMMA,
+	TOKEN_KEYWORD,
+	TOKEN_OPEN_PAREN,
+	TOKEN_OPERATOR,
+	TOKEN_IDENTIFIER,
+	TOKEN_STRING,
+	TOKEN_PERIOD,
+	TOKEN_OPEN_CURLY,
+	TOKEN_CLOSE_CURLY,
+	TOKEN_EQUAL_SIGN,
+	TOKEN_OPEN_SQUARE,
+	TOKEN_CLOSE_SQUARE,
+	TOKEN_VARIABLE,
+	TOKEN_AMPERSAND
+} tokenType;
+
+typedef struct {
+	tokenType		type;
+	keywordId		keyword;
+	vString *		string;
+	vString *		scope;
+	unsigned long 	lineNumber;
+	fpos_t			filePosition;
+	int 			parentKind; /* -1 if none */
+} tokenInfo;
+
+static langType Lang_php;
+
+static boolean InPhp = FALSE; /* whether we are between <? ?> */
+
+/* current statement details */
+static struct {
+	accessType access;
+	implType impl;
+} CurrentStatement;
 
-static void installPHPRegex (const langType language)
+/* Current namespace */
+static vString *CurrentNamesapce;
+
+
+static void buildPhpKeywordHash (void)
 {
-	addTagRegex(language, "(^|[ \t])class[ \t]+([" ALPHA "_][" ALNUM "_]*)",
-		"\\2", "c,class,classes", NULL);
-	addTagRegex(language, "(^|[ \t])interface[ \t]+([" ALPHA "_][" ALNUM "_]*)",
-		"\\2", "i,interface,interfaces", NULL);
-	addTagRegex(language, "(^|[ \t])define[ \t]*\\([ \t]*['\"]?([" ALPHA "_][" ALNUM "_]*)",
-		"\\2", "d,define,constant definitions", NULL);
-	addTagRegex(language, "(^|[ \t])function[ \t]+&?[ \t]*([" ALPHA "_][" ALNUM "_]*)",
-		"\\2", "f,function,functions", NULL);
-	addTagRegex(language, "(^|[ \t])(\\$|::\\$|\\$this->)([" ALPHA "_][" ALNUM "_]*)[ \t]*=",
-		"\\3", "v,variable,variables", NULL);
-	addTagRegex(language, "(^|[ \t])(var|public|protected|private|static)[ \t]+\\$([" ALPHA "_][" ALNUM "_]*)[ \t]*[=;]",
-		"\\3", "v,variable,variables", NULL);
-
-	/* function regex is covered by PHP regex */
-	addTagRegex (language, "(^|[ \t])([A-Za-z0-9_]+)[ \t]*[=:][ \t]*function[ \t]*\\(",
-		"\\2", "j,jsfunction,javascript functions", NULL);
-	addTagRegex (language, "(^|[ \t])([A-Za-z0-9_.]+)\\.([A-Za-z0-9_]+)[ \t]*=[ \t]*function[ \t]*\\(",
-		"\\2.\\3", "j,jsfunction,javascript functions", NULL);
-	addTagRegex (language, "(^|[ \t])([A-Za-z0-9_.]+)\\.([A-Za-z0-9_]+)[ \t]*=[ \t]*function[ \t]*\\(",
-		"\\3", "j,jsfunction,javascript functions", NULL);
+	const size_t count = sizeof (PhpKeywordTable) / sizeof (PhpKeywordTable[0]);
+	size_t i;
+	for (i = 0; i < count ; i++)
+	{
+		const keywordDesc* const p = &PhpKeywordTable[i];
+		addKeyword (p->name, Lang_php, (int) p->id);
+	}
 }
 
-/* Create parser definition structure */
-extern parserDefinition* PhpParser (void)
+static const char *accessToString (const accessType access)
 {
-	static const char *const extensions [] = { "php", "php3", "phtml", NULL };
-	parserDefinition* def = parserNew ("PHP");
-	def->extensions = extensions;
-	def->initialize = installPHPRegex;
-	def->regex      = TRUE;
-	return def;
+	static const char *const names[COUNT_ACCESS] = {
+		"undefined",
+		"private",
+		"protected",
+		"public"
+	};
+
+	Assert (access < COUNT_ACCESS);
+
+	return names[access];
+}
+
+static const char *implToString (const implType impl)
+{
+	static const char *const names[COUNT_IMPL] = {
+		"undefined",
+		"abstract"
+	};
+
+	Assert (impl < COUNT_IMPL);
+
+	return names[impl];
+}
+
+static void initPhpEntry (tagEntryInfo *const e, const tokenInfo *const token,
+						  const phpKind kind, const accessType access)
+{
+	static vString *fullScope = NULL;
+	int parentKind = -1;
+
+	if (fullScope == NULL)
+		fullScope = vStringNew ();
+	else
+		vStringClear (fullScope);
+
+	if (vStringLength (CurrentNamesapce) > 0)
+	{
+		vStringCopy (fullScope, CurrentNamesapce);
+		parentKind = K_NAMESPACE;
+	}
+
+	initTagEntry (e, vStringValue (token->string));
+
+	e->lineNumber	= token->lineNumber;
+	e->filePosition	= token->filePosition;
+	e->kindName		= PhpKinds[kind].name;
+	e->kind			= (char) PhpKinds[kind].letter;
+
+	if (access != ACCESS_UNDEFINED)
+		e->extensionFields.access = accessToString (access);
+	if (vStringLength (token->scope) > 0)
+	{
+		parentKind = token->parentKind;
+		if (vStringLength (fullScope) > 0)
+			vStringCatS (fullScope, SCOPE_SEPARATOR);
+		vStringCat (fullScope, token->scope);
+	}
+	if (vStringLength (fullScope) > 0)
+	{
+		Assert (parentKind >= 0);
+
+		vStringTerminate (fullScope);
+		e->extensionFields.scope[0] = PhpKinds[parentKind].name;
+		e->extensionFields.scope[1] = vStringValue (fullScope);
+	}
+}
+
+static void makeSimplePhpTag (const tokenInfo *const token, const phpKind kind,
+							  const accessType access)
+{
+	if (PhpKinds[kind].enabled)
+	{
+		tagEntryInfo e;
+
+		initPhpEntry (&e, token, kind, access);
+		makeTagEntry (&e);
+	}
+}
+
+static void makeNamespacePhpTag (const tokenInfo *const token, const vString *const name)
+{
+	if (PhpKinds[K_NAMESPACE].enabled)
+	{
+		tagEntryInfo e;
+
+		initTagEntry (&e, vStringValue (name));
+
+		e.lineNumber	= token->lineNumber;
+		e.filePosition	= token->filePosition;
+		e.kindName		= PhpKinds[K_NAMESPACE].name;
+		e.kind			= (char) PhpKinds[K_NAMESPACE].letter;
+
+		makeTagEntry (&e);
+	}
+}
+
+static void makeClassOrIfaceTag (const phpKind kind, const tokenInfo *const token,
+								 vString *const inheritance, const implType impl)
+{
+	if (PhpKinds[kind].enabled)
+	{
+		tagEntryInfo e;
+
+		initPhpEntry (&e, token, kind, ACCESS_UNDEFINED);
+
+		if (impl != IMPL_UNDEFINED)
+			e.extensionFields.implementation = implToString (impl);
+		if (vStringLength (inheritance) > 0)
+			e.extensionFields.inheritance = vStringValue (inheritance);
+
+		makeTagEntry (&e);
+	}
+}
+
+static void makeFunctionTag (const tokenInfo *const token,
+							 const vString *const arglist,
+							 const accessType access, const implType impl)
+{ 
+	if (PhpKinds[K_FUNCTION].enabled)
+	{
+		tagEntryInfo e;
+
+		initPhpEntry (&e, token, K_FUNCTION, access);
+
+		if (impl != IMPL_UNDEFINED)
+			e.extensionFields.implementation = implToString (impl);
+		if (arglist)
+			e.extensionFields.signature = vStringValue (arglist);
+
+		makeTagEntry (&e);
+	}
+}
+
+static tokenInfo *newToken (void)
+{
+	tokenInfo *const token = xMalloc (1, tokenInfo);
+
+	token->type			= TOKEN_UNDEFINED;
+	token->keyword		= KEYWORD_NONE;
+	token->string		= vStringNew ();
+	token->scope		= vStringNew ();
+	token->lineNumber   = getSourceLineNumber ();
+	token->filePosition = getInputFilePosition ();
+	token->parentKind	= -1;
+
+	return token;
+}
+
+static void deleteToken (tokenInfo *const token)
+{
+	vStringDelete (token->string);
+	vStringDelete (token->scope);
+	eFree (token);
+}
+
+static void copyToken (tokenInfo *const dest, const tokenInfo *const src,
+					   boolean scope)
+{
+	dest->lineNumber = src->lineNumber;
+	dest->filePosition = src->filePosition;
+	dest->type = src->type;
+	dest->keyword = src->keyword;
+	vStringCopy(dest->string, src->string);
+	dest->parentKind = src->parentKind;
+	if (scope)
+		vStringCopy(dest->scope, src->scope);
 }
 
 #if 0
+#include <stdio.h>
 
-static boolean isLetter(const int c)
+static const char *tokenTypeName (const tokenType type)
 {
-	return (boolean)(isalpha(c) || (c >= 127  &&  c <= 255));
+	switch (type)
+	{
+		case TOKEN_UNDEFINED:		return "undefined";
+		case TOKEN_EOF:				return "EOF";
+		case TOKEN_CHARACTER:		return "character";
+		case TOKEN_CLOSE_PAREN:		return "')'";
+		case TOKEN_SEMICOLON:		return "';'";
+		case TOKEN_COLON:			return "':'";
+		case TOKEN_COMMA:			return "','";
+		case TOKEN_OPEN_PAREN:		return "'('";
+		case TOKEN_OPERATOR:		return "operator";
+		case TOKEN_IDENTIFIER:		return "identifier";
+		case TOKEN_KEYWORD:			return "keyword";
+		case TOKEN_STRING:			return "string";
+		case TOKEN_PERIOD:			return "'.'";
+		case TOKEN_OPEN_CURLY:		return "'{'";
+		case TOKEN_CLOSE_CURLY:		return "'}'";
+		case TOKEN_EQUAL_SIGN:		return "'='";
+		case TOKEN_OPEN_SQUARE:		return "'['";
+		case TOKEN_CLOSE_SQUARE:	return "']'";
+		case TOKEN_VARIABLE:		return "variable";
+	}
+	return NULL;
 }
 
-static boolean isVarChar1(const int c)
+static void printToken (const tokenInfo *const token)
 {
-	return (boolean)(isLetter (c)  ||  c == '_');
+	fprintf (stderr, "%p:\n\ttype:\t%s\n\tline:\t%lu\n\tscope:\t%s\n", (void *) token,
+			 tokenTypeName (token->type),
+			 token->lineNumber,
+			 vStringValue (token->scope));
+	switch (token->type)
+	{
+		case TOKEN_IDENTIFIER:
+		case TOKEN_STRING:
+		case TOKEN_VARIABLE:
+			fprintf (stderr, "\tcontent:\t%s\n", vStringValue (token->string));
+			break;
+
+		case TOKEN_KEYWORD:
+		{
+			size_t n = sizeof PhpKeywordTable / sizeof PhpKeywordTable[0];
+			size_t i;
+
+			fprintf (stderr, "\tkeyword:\t");
+			for (i = 0; i < n; i++)
+			{
+				if (PhpKeywordTable[i].id == token->keyword)
+				{
+					fprintf (stderr, "%s\n", PhpKeywordTable[i].name);
+					break;
+				}
+			}
+			if (i >= n)
+				fprintf (stderr, "(unknown)\n");
+		}
+
+		default: break;
+	}
 }
+#endif
 
-static boolean isVarChar(const int c)
+static void addToScope (tokenInfo *const token, const vString *const extra)
 {
-	return (boolean)(isVarChar1 (c) || isdigit (c));
+	if (vStringLength (token->scope) > 0)
+		vStringCatS (token->scope, SCOPE_SEPARATOR);
+	vStringCatS (token->scope, vStringValue (extra));
+	vStringTerminate(token->scope);
 }
 
-static void findPhpTags (void)
+static boolean isIdentChar (const int c)
 {
-	vString *name = vStringNew ();
-	const unsigned char *line;
+	return (isalnum (c) || c == '_' || c >= 0x80);
+}
 
-	while ((line = fileReadLine ()) != NULL)
+static int skipToCharacter (const int c)
+{
+	int d;
+	do
 	{
-		const unsigned char *cp = line;
-		const char* f;
+		d = fileGetc ();
+	} while (d != EOF  &&  d != c);
+	return d;
+}
 
-		while (isspace (*cp))
-			cp++;
+static void parseString (vString *const string, const int delimiter)
+{
+	while (TRUE)
+	{
+		int c = fileGetc ();
+
+		if (c == '\\' && (c = fileGetc ()) != EOF)
+			vStringPut (string, (char) c);
+		else if (c == EOF || c == delimiter)
+			break;
+		else
+			vStringPut (string, (char) c);
+	}
+	vStringTerminate (string);
+}
 
-		if (*(const char*)cp == '$'  &&  isVarChar1 (*(const char*)(cp+1)))
+/* reads an HereDoc or a NowDoc (the part after the <<<).
+ * 	<<<[ \t]*(ID|'ID'|"ID")
+ * 	...
+ * 	ID;?
+ *
+ * note that:
+ *  1) starting ID must be immediately followed by a newline;
+ *  2) closing ID is the same as opening one;
+ *  3) closing ID must be immediately followed by a newline or a semicolon
+ *     then a newline.
+ *
+ * Example of a *single* valid heredoc:
+ * 	<<< FOO
+ * 	something
+ * 	something else
+ * 	FOO this is not an end
+ * 	FOO; this isn't either
+ * 	FOO; # neither this is
+ * 	FOO;
+ * 	# previous line was the end, but the semicolon wasn't required
+ */
+static void parseHeredoc (vString *const string)
+{
+	int c;
+	unsigned int len;
+	char delimiter[64]; /* arbitrary limit, but more is crazy anyway */
+	int quote = 0;
+
+	do
+	{
+		c = fileGetc ();
+	}
+	while (c == ' ' || c == '\t');
+
+	if (c == '\'' || c == '"')
+	{
+		quote = c;
+		c = fileGetc ();
+	}
+	for (len = 0; len < (sizeof delimiter / sizeof delimiter[0]) - 1; len++)
+	{
+		if (! isIdentChar (c))
+			break;
+		delimiter[len] = (char) c;
+		c = fileGetc ();
+	}
+	delimiter[len] = 0;
+
+	if (len == 0) /* no delimiter, give up */
+		goto error;
+	if (quote)
+	{
+		if (c != quote) /* no closing quote for quoted identifier, give up */
+			goto error;
+		c = fileGetc ();
+	}
+	if (c != '\r' && c != '\n') /* missing newline, give up */
+		goto error;
+
+	do
+	{
+		c = fileGetc ();
+
+		if (c != '\r' && c != '\n')
+			vStringPut (string, (char) c);
+		else
 		{
-			cp += 1;
-			vStringClear (name);
-			while (isVarChar ((int) *cp))
+			/* new line, check for a delimiter right after */
+			int nl = c;
+			int extra = EOF;
+
+			c = fileGetc ();
+			for (len = 0; c != 0 && (c - delimiter[len]) == 0; len++)
+				c = fileGetc ();
+
+			if (delimiter[len] != 0)
+				fileUngetc (c);
+			else
 			{
-				vStringPut (name, (int) *cp);
-				++cp;
+				/* line start matched the delimiter, now check whether there
+				 * is anything after it */
+				if (c == '\r' || c == '\n')
+				{
+					fileUngetc (c);
+					break;
+				}
+				else if (c == ';')
+				{
+					int d = fileGetc ();
+					if (d == '\r' || d == '\n')
+					{
+						/* put back the semicolon since it's not part of the
+						 * string.  we can't put back the newline, but it's a
+						 * whitespace character nobody cares about it anyway */
+						fileUngetc (';');
+						break;
+					}
+					else
+					{
+						/* put semicolon in the string and continue */
+						extra = ';';
+						fileUngetc (d);
+					}
+				}
 			}
-			while (isspace ((int) *cp))
-				++cp;
-			if (*(const char*) cp == '=')
+			/* if we are here it wasn't a delimiter, so put everything in the
+			 * string */
+			vStringPut (string, (char) nl);
+			vStringNCatS (string, delimiter, len);
+			if (extra != EOF)
+				vStringPut (string, (char) extra);
+		}
+	}
+	while (c != EOF);
+
+	vStringTerminate (string);
+
+	return;
+
+error:
+	fileUngetc (c);
+}
+
+static void parseIdentifier (vString *const string, const int firstChar)
+{
+	int c = firstChar;
+	do
+	{
+		vStringPut (string, (char) c);
+		c = fileGetc ();
+	} while (isIdentChar (c));
+	fileUngetc (c);
+	vStringTerminate (string);
+}
+
+static boolean isSpace (int c)
+{
+	return (c == '\t' || c == ' ' || c == '\v' ||
+			c == '\n' || c == '\r' || c == '\f');
+}
+
+static int skipWhitespaces (int c)
+{
+	while (isSpace (c))
+		c = fileGetc ();
+	return c;
+}
+
+/* <script[:white:]+language[:white:]*=[:white:]*(php|'php'|"php")[:white:]*>
+ * 
+ * This is ugly, but the whole "<script language=php>" tag is and we can't
+ * really do better without adding a lot of code only for this */
+static boolean isOpenScriptLanguagePhp (int c)
+{
+	int quote = 0;
+
+	/* <script[:white:]+language[:white:]*= */
+	if (c                                   != '<' ||
+		tolower ((c = fileGetc ()))         != 's' ||
+		tolower ((c = fileGetc ()))         != 'c' ||
+		tolower ((c = fileGetc ()))         != 'r' ||
+		tolower ((c = fileGetc ()))         != 'i' ||
+		tolower ((c = fileGetc ()))         != 'p' ||
+		tolower ((c = fileGetc ()))         != 't' ||
+		! isSpace ((c = fileGetc ()))              ||
+		tolower ((c = skipWhitespaces (c))) != 'l' ||
+		tolower ((c = fileGetc ()))         != 'a' ||
+		tolower ((c = fileGetc ()))         != 'n' ||
+		tolower ((c = fileGetc ()))         != 'g' ||
+		tolower ((c = fileGetc ()))         != 'u' ||
+		tolower ((c = fileGetc ()))         != 'a' ||
+		tolower ((c = fileGetc ()))         != 'g' ||
+		tolower ((c = fileGetc ()))         != 'e' ||
+		(c = skipWhitespaces (fileGetc ())) != '=')
+		return FALSE;
+
+	/* (php|'php'|"php")> */
+	c = skipWhitespaces (fileGetc ());
+	if (c == '"' || c == '\'')
+	{
+		quote = c;
+		c = fileGetc ();
+	}
+	if (tolower (c)                         != 'p' ||
+		tolower ((c = fileGetc ()))         != 'h' ||
+		tolower ((c = fileGetc ()))         != 'p' ||
+		(quote != 0 && (c = fileGetc ()) != quote) ||
+		(c = skipWhitespaces (fileGetc ())) != '>')
+		return FALSE;
+
+	return TRUE;
+}
+
+static int findPhpStart (void)
+{
+	int c;
+	do
+	{
+		if ((c = fileGetc ()) == '<')
+		{
+			c = fileGetc ();
+			/* <? and <?php, but not <?xml */
+			if (c == '?')
 			{
-				vStringTerminate (name);
-				makeSimpleTag (name, PhpKinds, K_VARIABLE);
-				vStringClear (name);
+				/* don't enter PHP mode on "<?xml", yet still support short open tags (<?) */
+				if (tolower ((c = fileGetc ())) != 'x' ||
+					tolower ((c = fileGetc ())) != 'm' ||
+					tolower ((c = fileGetc ())) != 'l')
+				{
+					break;
+				}
+			}
+			/* <script language="php"> */
+			else
+			{
+				fileUngetc (c);
+				if (isOpenScriptLanguagePhp ('<'))
+					break;
 			}
 		}
-		else if ((f = strstr ((const char*) cp, "function")) != NULL &&
-			(f == (const char*) cp || isspace ((int) f [-1])) &&
-			isspace ((int) f [8]))
+	}
+	while (c != EOF);
+
+	return c;
+}
+
+static int skipSingleComment (void)
+{
+	int c;
+	do
+	{
+		c = fileGetc ();
+		if (c == '\r')
 		{
-			cp = ((const unsigned char *) f) + 8;
+			int next = fileGetc ();
+			if (next != '\n')
+				fileUngetc (next);
+			else
+				c = next;
+		}
+		/* ?> in single-line comments leaves PHP mode */
+		else if (c == '?')
+		{
+			int next = fileGetc ();
+			if (next == '>')
+				InPhp = FALSE;
+			else
+				fileUngetc (next);
+		}
+	} while (InPhp && c != EOF && c != '\n' && c != '\r');
+	return c;
+}
+
+static void readToken (tokenInfo *const token)
+{
+	int c;
 
-			while (isspace ((int) *cp))
-				++cp;
+	token->type		= TOKEN_UNDEFINED;
+	token->keyword	= KEYWORD_NONE;
+	vStringClear (token->string);
 
-			if (*cp == '&')	/* skip reference character and following whitespace */
+getNextChar:
+
+	if (! InPhp)
+	{
+		c = findPhpStart ();
+		if (c != EOF)
+			InPhp = TRUE;
+	}
+	else
+		c = fileGetc ();
+
+	c = skipWhitespaces (c);
+
+	token->lineNumber   = getSourceLineNumber ();
+	token->filePosition = getInputFilePosition ();
+
+	switch (c)
+	{
+		case EOF: token->type = TOKEN_EOF;					break;
+		case '(': token->type = TOKEN_OPEN_PAREN;			break;
+		case ')': token->type = TOKEN_CLOSE_PAREN;			break;
+		case ';': token->type = TOKEN_SEMICOLON;			break;
+		case ',': token->type = TOKEN_COMMA;				break;
+		case '.': token->type = TOKEN_PERIOD;				break;
+		case ':': token->type = TOKEN_COLON;				break;
+		case '{': token->type = TOKEN_OPEN_CURLY;			break;
+		case '}': token->type = TOKEN_CLOSE_CURLY;			break;
+		case '[': token->type = TOKEN_OPEN_SQUARE;			break;
+		case ']': token->type = TOKEN_CLOSE_SQUARE;			break;
+		case '&': token->type = TOKEN_AMPERSAND;			break;
+
+		case '=':
+		{
+			int d = fileGetc ();
+			if (d == '=' || d == '>')
+				token->type = TOKEN_OPERATOR;
+			else
 			{
-				cp++;
+				fileUngetc (d);
+				token->type = TOKEN_EQUAL_SIGN;
+			}
+			break;
+		}
 
-				while (isspace ((int) *cp))
-					++cp; 
+		case '\'':
+		case '"':
+			token->type = TOKEN_STRING;
+			parseString (token->string, c);
+			token->lineNumber = getSourceLineNumber ();
+			token->filePosition = getInputFilePosition ();
+			break;
+
+		case '<':
+		{
+			int d = fileGetc ();
+			if (d == '/')
+			{
+				/* </script[:white:]*> */
+				if (tolower ((d = fileGetc ())) == 's' &&
+					tolower ((d = fileGetc ())) == 'c' &&
+					tolower ((d = fileGetc ())) == 'r' &&
+					tolower ((d = fileGetc ())) == 'i' &&
+					tolower ((d = fileGetc ())) == 'p' &&
+					tolower ((d = fileGetc ())) == 't' &&
+					(d = skipWhitespaces (fileGetc ())) == '>')
+				{
+					InPhp = FALSE;
+					goto getNextChar;
+				}
+				else
+				{
+					fileUngetc (d);
+					token->type = TOKEN_UNDEFINED;
+				}
+			}
+			else if (d == '<' && (d = fileGetc ()) == '<')
+			{
+				token->type = TOKEN_STRING;
+				parseHeredoc (token->string);
 			}
+			else
+			{
+				fileUngetc (d);
+				token->type = TOKEN_UNDEFINED;
+			}
+			break;
+		}
 
-			vStringClear (name);
-			while (isalnum ((int) *cp)  ||  *cp == '_')
+		case '#': /* comment */
+			skipSingleComment ();
+			goto getNextChar;
+			break;
+
+		case '+':
+		case '-':
+		case '*':
+		case '%':
+		{
+			int d = fileGetc ();
+			if (d != '=')
+				fileUngetc (d);
+			token->type = TOKEN_OPERATOR;
+			break;
+		}
+
+		case '/': /* division or comment start */
+		{
+			int d = fileGetc ();
+			if (d == '/') /* single-line comment */
 			{
-				vStringPut (name, (int) *cp);
-				++cp;
+				skipSingleComment ();
+				goto getNextChar;
 			}
-			vStringTerminate (name);
-			makeSimpleTag (name, PhpKinds, K_FUNCTION);
-			vStringClear (name);
-		} 
-		else if (strncmp ((const char*) cp, "class", (size_t) 5) == 0 &&
-				 isspace ((int) cp [5]))
+			else if (d == '*')
+			{
+				do
+				{
+					c = skipToCharacter ('*');
+					if (c != EOF)
+					{
+						c = fileGetc ();
+						if (c == '/')
+							break;
+						else
+							fileUngetc (c);
+					}
+				} while (c != EOF && c != '\0');
+				goto getNextChar;
+			}
+			else
+			{
+				if (d != '=')
+					fileUngetc (d);
+				token->type = TOKEN_OPERATOR;
+			}
+			break;
+		}
+
+		case '$': /* variable start */
 		{
-			cp += 5;
+			int d = fileGetc ();
+			if (! isIdentChar (d))
+			{
+				fileUngetc (d);
+				token->type = TOKEN_UNDEFINED;
+			}
+			else
+			{
+				parseIdentifier (token->string, d);
+				token->type = TOKEN_VARIABLE;
+			}
+			break;
+		}
 
-			while (isspace ((int) *cp))
-				++cp;
-			vStringClear (name);
-			while (isalnum ((int) *cp)  ||  *cp == '_')
+		case '?': /* maybe the end of the PHP chunk */
+		{
+			int d = fileGetc ();
+			if (d == '>')
 			{
-				vStringPut (name, (int) *cp);
-				++cp;
+				InPhp = FALSE;
+				goto getNextChar;
 			}
-			vStringTerminate (name);
-			makeSimpleTag (name, PhpKinds, K_CLASS);
-			vStringClear (name);
+			else
+			{
+				fileUngetc (d);
+				token->type = TOKEN_UNDEFINED;
+			}
+			break;
 		}
-		else if (strncmp ((const char*) cp, "define", (size_t) 6) == 0 &&
-				 ! isalnum ((int) cp [6]))
+
+		default:
+			if (! isIdentChar (c))
+				token->type = TOKEN_UNDEFINED;
+			else
+			{
+				parseIdentifier (token->string, c);
+				token->keyword = analyzeToken (token->string, Lang_php);
+				if (token->keyword == KEYWORD_NONE)
+					token->type = TOKEN_IDENTIFIER;
+				else
+					token->type = TOKEN_KEYWORD;
+			}
+			break;
+	}
+
+	if (token->type == TOKEN_SEMICOLON ||
+		token->type == TOKEN_OPEN_CURLY ||
+		token->type == TOKEN_CLOSE_CURLY)
+	{
+		/* reset current statement details on statement end, and when entering
+		 * a deeper scope.
+		 * it is a bit ugly to do this in readToken(), but it makes everything
+		 * a lot simpler. */
+		CurrentStatement.access = ACCESS_UNDEFINED;
+		CurrentStatement.impl = IMPL_UNDEFINED;
+	}
+}
+
+static void enterScope (tokenInfo *const parentToken,
+						const vString *const extraScope,
+						const int parentKind);
+
+/* parses a class or an interface:
+ * 	class Foo {}
+ * 	class Foo extends Bar {}
+ * 	class Foo extends Bar implements iFoo, iBar {}
+ * 	interface iFoo {}
+ * 	interface iBar extends iFoo {} */
+static boolean parseClassOrIface (tokenInfo *const token, const phpKind kind)
+{
+	boolean readNext = TRUE;
+	implType impl = CurrentStatement.impl;
+	tokenInfo *name;
+	vString *inheritance = NULL;
+
+	readToken (token);
+	if (token->type != TOKEN_IDENTIFIER)
+		return FALSE;
+
+	name = newToken ();
+	copyToken (name, token, TRUE);
+
+	inheritance = vStringNew ();
+	/* skip until the open bracket and assume every identifier (not keyword)
+	 * is an inheritance (like in "class Foo extends Bar implements iA, iB") */
+	do
+	{
+		readToken (token);
+
+		if (token->type == TOKEN_IDENTIFIER)
+		{
+			if (vStringLength (inheritance) > 0)
+				vStringPut (inheritance, ',');
+			vStringCat (inheritance, token->string);
+		}
+	}
+	while (token->type != TOKEN_EOF &&
+		   token->type != TOKEN_OPEN_CURLY);
+
+	makeClassOrIfaceTag (kind, name, inheritance, impl);
+
+	if (token->type == TOKEN_OPEN_CURLY)
+		enterScope (token, name->string, K_CLASS);
+	else
+		readNext = FALSE;
+
+	deleteToken (name);
+	vStringDelete (inheritance);
+
+	return readNext;
+}
+
+/* parses a trait:
+ * 	trait Foo {} */
+static boolean parseTrait (tokenInfo *const token)
+{
+	boolean readNext = TRUE;
+	tokenInfo *name;
+
+	readToken (token);
+	if (token->type != TOKEN_IDENTIFIER)
+		return FALSE;
+
+	name = newToken ();
+	copyToken (name, token, TRUE);
+
+	makeSimplePhpTag (name, K_TRAIT, ACCESS_UNDEFINED);
+
+	readToken (token);
+	if (token->type == TOKEN_OPEN_CURLY)
+		enterScope (token, name->string, K_TRAIT);
+	else
+		readNext = FALSE;
+
+	deleteToken (name);
+
+	return readNext;
+}
+
+/* parse a function
+ *
+ * if @name is NULL, parses a normal function
+ * 	function myfunc($foo, $bar) {}
+ * 	function &myfunc($foo, $bar) {}
+ *
+ * if @name is not NULL, parses an anonymous function with name @name
+ * 	$foo = function($foo, $bar) {}
+ * 	$foo = function&($foo, $bar) {}
+ * 	$foo = function($foo, $bar) use ($x, &$y) {} */
+static boolean parseFunction (tokenInfo *const token, const tokenInfo *name)
+{
+	boolean readNext = TRUE;
+	accessType access = CurrentStatement.access;
+	implType impl = CurrentStatement.impl;
+	tokenInfo *nameFree = NULL;
+
+	readToken (token);
+	/* skip a possible leading ampersand (return by reference) */
+	if (token->type == TOKEN_AMPERSAND)
+		readToken (token);
+
+	if (! name)
+	{
+		if (token->type != TOKEN_IDENTIFIER)
+			return FALSE;
+
+		name = nameFree = newToken ();
+		copyToken (nameFree, token, TRUE);
+		readToken (token);
+	}
+
+	if (token->type == TOKEN_OPEN_PAREN)
+	{
+		vString *arglist = vStringNew ();
+		int depth = 1;
+
+		vStringPut (arglist, '(');
+		do
 		{
-			cp += 6;
+			readToken (token);
 
-			while (isspace ((int) *cp))
-				++cp;
-			if (*cp != '(')
-				continue;
-			++cp;
+			switch (token->type)
+			{
+				case TOKEN_OPEN_PAREN:  depth++; break;
+				case TOKEN_CLOSE_PAREN: depth--; break;
+				default: break;
+			}
+			/* display part */
+			switch (token->type)
+			{
+				case TOKEN_AMPERSAND:		vStringPut (arglist, '&');		break;
+				case TOKEN_CLOSE_CURLY:		vStringPut (arglist, '}');		break;
+				case TOKEN_CLOSE_PAREN:		vStringPut (arglist, ')');		break;
+				case TOKEN_CLOSE_SQUARE:	vStringPut (arglist, ']');		break;
+				case TOKEN_COLON:			vStringPut (arglist, ':');		break;
+				case TOKEN_COMMA:			vStringCatS (arglist, ", ");	break;
+				case TOKEN_EQUAL_SIGN:		vStringCatS (arglist, " = ");	break;
+				case TOKEN_OPEN_CURLY:		vStringPut (arglist, '{');		break;
+				case TOKEN_OPEN_PAREN:		vStringPut (arglist, '(');		break;
+				case TOKEN_OPEN_SQUARE:		vStringPut (arglist, '[');		break;
+				case TOKEN_PERIOD:			vStringPut (arglist, '.');		break;
+				case TOKEN_SEMICOLON:		vStringPut (arglist, ';');		break;
+				case TOKEN_STRING:			vStringCatS (arglist, "'...'");	break;
+
+				case TOKEN_IDENTIFIER:
+				case TOKEN_KEYWORD:
+				case TOKEN_VARIABLE:
+				{
+					switch (vStringLast (arglist))
+					{
+						case 0:
+						case ' ':
+						case '{':
+						case '(':
+						case '[':
+						case '.':
+							/* no need for a space between those and the identifier */
+							break;
+
+						default:
+							vStringPut (arglist, ' ');
+							break;
+					}
+					if (token->type == TOKEN_VARIABLE)
+						vStringPut (arglist, '$');
+					vStringCat (arglist, token->string);
+					break;
+				}
+
+				default: break;
+			}
+		}
+		while (token->type != TOKEN_EOF && depth > 0);
+
+		vStringTerminate (arglist);
+
+		makeFunctionTag (name, arglist, access, impl);
+		vStringDelete (arglist);
+
+		readToken (token); /* normally it's an open brace or "use" keyword */
+	}
+
+	/* skip use(...) */
+	if (token->type == TOKEN_KEYWORD && token->keyword == KEYWORD_use)
+	{
+		readToken (token);
+		if (token->type == TOKEN_OPEN_PAREN)
+		{
+			int depth = 1;
 
-			while (isspace ((int) *cp))
-				++cp;
-			if ((*cp == '\'') || (*cp == '"'))
-				++cp;
-			else if (! ((*cp == '_')  || isalnum ((int) *cp)))
-				continue;
-	      
-			vStringClear (name);
-			while (isalnum ((int) *cp)  ||  *cp == '_')
+			do
 			{
-				vStringPut (name, (int) *cp);
-				++cp;
+				readToken (token);
+				switch (token->type)
+				{
+					case TOKEN_OPEN_PAREN:  depth++; break;
+					case TOKEN_CLOSE_PAREN: depth--; break;
+					default: break;
+				}
 			}
-			vStringTerminate (name);
-			makeSimpleTag (name, PhpKinds, K_DEFINE);
-			vStringClear (name);
+			while (token->type != TOKEN_EOF && depth > 0);
+
+			readToken (token);
 		}
 	}
-	vStringDelete (name);
+
+	if (token->type == TOKEN_OPEN_CURLY)
+		enterScope (token, name->string, K_FUNCTION);
+	else
+		readNext = FALSE;
+
+	if (nameFree)
+		deleteToken (nameFree);
+
+	return readNext;
+}
+
+/* parses declarations of the form
+ * 	const NAME = VALUE */
+static boolean parseConstant (tokenInfo *const token)
+{
+	tokenInfo *name;
+
+	readToken (token); /* skip const keyword */
+	if (token->type != TOKEN_IDENTIFIER)
+		return FALSE;
+
+	name = newToken ();
+	copyToken (name, token, TRUE);
+
+	readToken (token);
+	if (token->type == TOKEN_EQUAL_SIGN)
+		makeSimplePhpTag (name, K_DEFINE, ACCESS_UNDEFINED);
+
+	deleteToken (name);
+
+	return token->type == TOKEN_EQUAL_SIGN;
+}
+
+/* parses declarations of the form
+ * 	define('NAME', 'VALUE')
+ * 	define(NAME, 'VALUE) */
+static boolean parseDefine (tokenInfo *const token)
+{
+	int depth = 1;
+
+	readToken (token); /* skip "define" identifier */
+	if (token->type != TOKEN_OPEN_PAREN)
+		return FALSE;
+
+	readToken (token);
+	if (token->type == TOKEN_STRING ||
+		token->type == TOKEN_IDENTIFIER)
+	{
+		makeSimplePhpTag (token, K_DEFINE, ACCESS_UNDEFINED);
+		readToken (token);
+	}
+
+	/* skip until the close parenthesis.
+	 * no need to handle nested blocks since they would be invalid
+	 * in this context anyway (the VALUE may only be a scalar, like
+	 * 	42
+	 * 	(42)
+	 * and alike) */
+	while (token->type != TOKEN_EOF && depth > 0)
+	{
+		switch (token->type)
+		{
+			case TOKEN_OPEN_PAREN:	depth++; break;
+			case TOKEN_CLOSE_PAREN:	depth--; break;
+			default: break;
+		}
+		readToken (token);
+	}
+
+	return FALSE;
+}
+
+/* parses declarations of the form
+ * 	$var = VALUE
+ * 	$var; */
+static boolean parseVariable (tokenInfo *const token)
+{
+	tokenInfo *name;
+	boolean readNext = TRUE;
+	accessType access = CurrentStatement.access;
+
+	name = newToken ();
+	copyToken (name, token, TRUE);
+
+	readToken (token);
+	if (token->type == TOKEN_EQUAL_SIGN)
+	{
+		phpKind kind = K_VARIABLE;
+
+		if (token->parentKind == K_FUNCTION)
+			kind = K_LOCAL_VARIABLE;
+
+		readToken (token);
+		if (token->type == TOKEN_KEYWORD &&
+			token->keyword == KEYWORD_function &&
+			PhpKinds[kind].enabled)
+		{
+			if (parseFunction (token, name))
+				readToken (token);
+			readNext = (boolean) (token->type == TOKEN_SEMICOLON);
+		}
+		else
+		{
+			makeSimplePhpTag (name, kind, access);
+			readNext = FALSE;
+		}
+	}
+	else if (token->type == TOKEN_SEMICOLON)
+	{
+		/* generate tags for variable declarations in classes
+		 * 	class Foo {
+		 * 		protected $foo;
+		 * 	}
+		 * but don't get fooled by stuff like $foo = $bar; */
+		if (token->parentKind == K_CLASS || token->parentKind == K_INTERFACE)
+			makeSimplePhpTag (name, K_VARIABLE, access);
+	}
+	else
+		readNext = FALSE;
+
+	deleteToken (name);
+
+	return readNext;
+}
+
+/* parses namespace declarations
+ * 	namespace Foo {}
+ * 	namespace Foo\Bar {}
+ * 	namespace Foo;
+ * 	namespace Foo\Bar;
+ * 	namespace;
+ * 	napespace {} */
+static boolean parseNamespace (tokenInfo *const token)
+{
+	tokenInfo *nsToken = newToken ();
+
+	vStringClear (CurrentNamesapce);
+	copyToken (nsToken, token, FALSE);
+
+	do
+	{
+		readToken (token);
+		if (token->type == TOKEN_IDENTIFIER)
+		{
+			if (vStringLength (CurrentNamesapce) > 0)
+				vStringPut (CurrentNamesapce, '\\');
+			vStringCat (CurrentNamesapce, token->string);
+		}
+	}
+	while (token->type != TOKEN_EOF &&
+		   token->type != TOKEN_SEMICOLON &&
+		   token->type != TOKEN_OPEN_CURLY);
+
+	vStringTerminate (CurrentNamesapce);
+	if (vStringLength (CurrentNamesapce) > 0)
+		makeNamespacePhpTag (nsToken, CurrentNamesapce);
+
+	if (token->type == TOKEN_OPEN_CURLY)
+		enterScope (token, NULL, -1);
+
+	deleteToken (nsToken);
+
+	return TRUE;
+}
+
+static void enterScope (tokenInfo *const parentToken,
+						const vString *const extraScope,
+						const int parentKind)
+{
+	tokenInfo *token = newToken ();
+	int origParentKind = parentToken->parentKind;
+
+	copyToken (token, parentToken, TRUE);
+
+	if (extraScope)
+	{
+		addToScope (token, extraScope);
+		token->parentKind = parentKind;
+	}
+
+	readToken (token);
+	while (token->type != TOKEN_EOF &&
+		   token->type != TOKEN_CLOSE_CURLY)
+	{
+		boolean readNext = TRUE;
+
+		switch (token->type)
+		{
+			case TOKEN_OPEN_CURLY:
+				enterScope (token, NULL, -1);
+				break;
+
+			case TOKEN_KEYWORD:
+				switch (token->keyword)
+				{
+					case KEYWORD_class:		readNext = parseClassOrIface (token, K_CLASS);		break;
+					case KEYWORD_interface:	readNext = parseClassOrIface (token, K_INTERFACE);	break;
+					case KEYWORD_trait:		readNext = parseTrait (token);						break;
+					case KEYWORD_function:	readNext = parseFunction (token, NULL);				break;
+					case KEYWORD_const:		readNext = parseConstant (token);					break;
+					case KEYWORD_define:	readNext = parseDefine (token);						break;
+
+					case KEYWORD_namespace:	readNext = parseNamespace (token);	break;
+
+					case KEYWORD_private:	CurrentStatement.access = ACCESS_PRIVATE;	break;
+					case KEYWORD_protected:	CurrentStatement.access = ACCESS_PROTECTED;	break;
+					case KEYWORD_public:	CurrentStatement.access = ACCESS_PUBLIC;	break;
+					case KEYWORD_var:		CurrentStatement.access = ACCESS_PUBLIC;	break;
+
+					case KEYWORD_abstract:	CurrentStatement.impl = IMPL_ABSTRACT;		break;
+
+					default: break;
+				}
+				break;
+
+			case TOKEN_VARIABLE:
+				readNext = parseVariable (token);
+				break;
+
+			default: break;
+		}
+
+		if (readNext)
+			readToken (token);
+	}
+
+	copyToken (parentToken, token, FALSE);
+	parentToken->parentKind = origParentKind;
+	deleteToken (token);
+}
+
+static void findPhpTags (void)
+{
+	tokenInfo *const token = newToken ();
+
+	InPhp = FALSE;
+	CurrentStatement.access = ACCESS_UNDEFINED;
+	CurrentStatement.impl = IMPL_UNDEFINED;
+	CurrentNamesapce = vStringNew ();
+
+	do
+	{
+		enterScope (token, NULL, -1);
+	}
+	while (token->type != TOKEN_EOF); /* keep going even with unmatched braces */
+
+	vStringDelete (CurrentNamesapce);
+	deleteToken (token);
+}
+
+static void initialize (const langType language)
+{
+	Lang_php = language;
+	buildPhpKeywordHash ();
 }
 
 extern parserDefinition* PhpParser (void)
 {
-	static const char *const extensions [] = { "php", "php3", "phtml", NULL };
+	static const char *const extensions [] = { "php", "php3", "php4", "php5", "phtml", NULL };
 	parserDefinition* def = parserNew ("PHP");
 	def->kinds      = PhpKinds;
 	def->kindCount  = KIND_COUNT (PhpKinds);
 	def->extensions = extensions;
 	def->parser     = findPhpTags;
+	def->initialize = initialize;
 	return def;
 }
 
-#endif
-
 /* vi:set tabstop=4 shiftwidth=4: */
