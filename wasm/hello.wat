;; Módulo WebAssembly en formato de texto (WAT).
;; Para cambiar el programa, edita este archivo y vuelve a compilar.

(module
  ;; Memoria lineal compartida con JavaScript.
  (memory (export "memory") 1)

  ;; Texto guardado en la posición 0 de la memoria.
  (data (i32.const 0) "Hello, WebAssembly!")

  ;; Devuelve la posición donde empieza el texto.
  (func (export "message_ptr") (result i32)
    i32.const 0)

  ;; Devuelve la longitud del texto (19 caracteres).
  (func (export "message_len") (result i32)
    i32.const 19)

  ;; Función de ejemplo: suma dos enteros.
  (func (export "add") (param $a i32) (param $b i32) (result i32)
    local.get $a
    local.get $b
    i32.add)
)
