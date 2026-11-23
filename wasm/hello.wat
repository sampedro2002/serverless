;; WebAssembly module in text format (WAT).
;; To change the program, edit this file and rebuild.

(module
  ;; Linear memory shared with JavaScript.
  (memory (export "memory") 1)

  ;; Text stored at position 0 of the memory.
  (data (i32.const 0) "Hello, WebAssembly!")

  ;; Returns the position where the text starts.
  (func (export "message_ptr") (result i32)
    i32.const 0)

  ;; Returns the length of the text (19 characters).
  (func (export "message_len") (result i32)
    i32.const 19)

  ;; Example function: adds two integers.
  (func (export "add") (param $a i32) (param $b i32) (result i32)
    local.get $a
    local.get $b
    i32.add)
)
