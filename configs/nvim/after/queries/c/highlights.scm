;; extends
((call_expression
  function: (identifier) @keyword)
  (#any-of? @keyword "gets" "strcpy" "sprintf" "system" "popen"))
