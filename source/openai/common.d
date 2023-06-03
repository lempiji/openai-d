/**
OpenAI API Client
*/
module openai.common;

import mir.algebraic;

@safe:

///
alias StopToken = Algebraic!(typeof(null), string, string[]);
