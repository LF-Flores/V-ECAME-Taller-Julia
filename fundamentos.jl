### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 98ab1365-b894-4789-85e2-5b36ab05593c
begin
	using Pkg; Pkg.activate("..")  # Se indica cuál ambiente virtual usaremos
	using PlutoUI                  # Para elementos interactivos en Pluto.
	using Plots                    # Paquete básico de gráficos
	using LinearAlgebra            # Paquete dentro de la base de Julia.
end

# ╔═╡ c4ad90dc-b5f0-11eb-0fcf-c75235c9ff14
md"# Temario del taller
1. Fundamentos del lenguaje
2. 



# Fundamentos del lenguaje Julia
## Descripción general del lenguaje

El lenguaje Julia es un lenguaje de propósito general con un fuerte enfoque en cómputo científico de alto rendimiento y análisis numérico. Tiene raíces más en el espectro del paradigma funcional, lo cual puede ser un contraste respecto a quienes acostumbran a usar lenguajes orientados a objetos, pero al mismo tiempo será algo refrescante.

Por otro lado, mencionemos características específicas del lenguaje, quizá un poco técnicas para este momento, pero que describen para futura referencia el lenguaje:

- **Multiple Dispatch (Polimorfismo paramétrico)**,
- **Compilación JIT (Just-In-Time), a veces mejor referida como JAOT (just-ahead-of-time)**,
- **Cómputo concurrente y paralelo nativo (con o sin MPI)**,
- **Interfaz o llamado directo, amigable y eficiente a otros lenguajes incluyendo C, Fortran, Python**,
- **Con recolector de basura**
- **... muchas más cosas.** Leer [la documentación](https://docs.julialang.org/en/v1/) y la [páginas del taller pasado](https://juliaforeducation.github.io/Intro-Julia-2021/Fundamentos.html)


## Aspectos importantes a cubrir
- Tipos primitivos y compuestos
- Sintaxis general para programación estructurada
- Nociones de 'scope' (ámbito o alcance)

...

## Funciones y tipos primitivos
### Manipulando funciones
Para comenzar a comprender el lenguaje, ensuciémonos las manos manipulando las siguientes dos funciones:
"

# ╔═╡ 0d213fe4-7134-4b29-ac25-e9040bec6f28
md"Una de las metas de la sintaxis de Julia es ser lo más legible y cercana a lo 'escrito en papel' posible. Podemos también evaluarlas como esperaríamos:"

# ╔═╡ 6aeed4ab-aa87-4d77-a006-76faa391bceb
md"Notemos que la imagen de $f$ resultó mostrarse como 2.0 mientras que la de $g$ no tiene punto decimal. Esto es por el tipo de dato de salida que ha resultado de la evaluación:"

# ╔═╡ 88236333-85b1-4ef5-ae74-d67e94f74f9b
md"Esto es porque hemos utilizado números enteros como preimagen y $g$ no realiza operaciones que nos saquen de los enteros mientras que $f$ sí (la raiz cuadrada).

Observemos que la misma operación anterior podemos realizarla de esta manera:"

# ╔═╡ b77774cd-f370-423e-9155-9b91f67e1622
md"A esto se le llama *'broadcasting'* o *'difusión'* de una función. En este caso la función `typeof`. Veremos más de ello luego.

Graficar las funciones es tan sencillo como decir `plot(g)`"

# ╔═╡ bfb35ee8-163f-422e-bffe-f533beafd78c
md"Aunque, por supuesto, podemos hacer mucha personalización:"

# ╔═╡ 18c42908-e4e1-4e1b-af86-d4a46da837ef
md"
Notemos el signo de admiración (o *bang*), `!`, al final de todas las funciones siguientes al primer `plot`. Esta es una convención en Julia para denotar funciones que **modifican sus argumentos o el estado del programa**. En el caso de arriba, cada función luego de la primera tiene como argumento implícito el plot que retornó el primero llamado a `plot`.

### Extendiendo operadores

Hay algunas operaciones que son muy intuitivas en la matemática que hacemos día a día y podríamos querer definirlas para usarlas en Julia:
- **Multiplicación de un número con una función:** es decir, que $a\cdot f$ sea la nueva función tal que para todo $x$ para el cual $f$ está definido, tenemos $(a \cdot f)(x) = a \cdot f(x)$ 
- **Pensar en la multiplicación de dos funciones como su composición:** es decir, que $f \times g = f \circ g$
- **Que multiplicar una función $f$ por un escalar, $a$ a la derecha, significa que estamos escalando su argumento por $a$**

Podemos definir las tres nuevas operaciones fácilmente:
"

# ╔═╡ c41fd8d5-ed76-4bc1-86c2-8a7f1661168c
begin
	import Base: *  # Ocupamos importar la función `*` explícitamente
	                # para modificarla
	*(f::Function, g::Function) = x -> f(g(x))
	*(a::Number, f::Function) = x -> a*f(x)
	*(f::Function, a::Number) = x -> f(a*x)
end

# ╔═╡ 75b26f6d-1223-4bab-bbde-94f879aa8b07
md"Probémos nuestras nuevas definiciones:"

# ╔═╡ b66189d7-4d81-4bd5-ae45-70368c519340
md"Lo que está sucediendo en las celdas anteriores es que llamamos anteriormente **multiple dispatch**, que yace en el corazón de Julia. Es la propiedad de las funciones de poder tener múltiples significados dependiendo del contexto de los tipos de sus argumentos.

En ese sentido, Julia construye tanto su fácil sintaxis así como su alta velocidad (tras una eficiente compilación) en este robusto pero sencillo [sistema de tipos](https://en.wikipedia.org/wiki/Type_system).

### Tipos primitivos

Los *tipos primitivos* (tipos de dato que ya están definidos en el lenguaje) son los siguientes:

1. `Integer`, de donde tenemos enteros específicos según el número de bits utilizado en su representación: `Int64`, `Int32`, `Int128`, `Int8`, etc.
2. `AbstractFloat`, de donde tenemos [números de punto flotante](https://en.wikipedia.org/wiki/Floating-point_arithmetic) específicos según el número de bits utilizado en su representación: `Float64`, `Float32`, etc.
3. `Irrational`
4. `Bool`
5. `String` y `Char`
6. `Complex`

Practiquemos los tipos definiendo una *función genérica con varios métodos* (lo mismo que hicimos anteriormente con la multiplicación `*`).

"

# ╔═╡ fc857690-684c-41fc-b37e-c8ec02aac3a3
md"Esta granularidad de elegir un comportamiento por tipo de dato, incluso dentro de la misma 'clase conceptual' de tipo (ejemplo: 'enteros'), nos permite reaccionar hacia actuar de formas distintas acorde a la precisión de dato que tengamos..."

# ╔═╡ 78244bfc-4bf9-4fcc-b2e6-08fff994365a
md"... o reaccionar al tipo de matriz que tenemos:"

# ╔═╡ da26fd9e-992c-48b1-9bef-8dca240529aa
A = [1.5 2 -4; 3 -1 -6; -10 2.3 4]

# ╔═╡ c058b5dd-3a6e-42d5-9c2c-a574a04cc11a
factorize(A)

# ╔═╡ c91a1ef0-6520-4a30-9c5c-b36fb79cdeeb
md"La matriz $A$ arriba definida no tiene propiedades de ser ni simétrica, triangular, bidiagonal ni tridiagonal, así que la función `factorize` reacciona hacia lo mejor que puede hacer: Una factorización LU.

Por otro lado, si definimos una matriz que sí es simétrica:"

# ╔═╡ 13e0a04c-03f5-44ef-b7dd-7679743f4bfa
B = [1.5 2 -4; 2 -1 -3; -4 -3 5]

# ╔═╡ 5c4c1ceb-38b4-43ed-837c-21ba34bb56af
factorize(B)

# ╔═╡ d3822674-f3c4-4066-9227-c8af13a3e005
md"Notemos que los tipos los datos retornados son respectivamente `Tridiagonal{Float64, Vector{Float64}}` y `UnitUpperTriangular{Float64, Matrix{Float64}}` y `Vector{Int64}`. 

La parte dentro de los corchetes/llaves se explicará en detalle luego. Estos son ejemplo de **tipos compuestos** interesantes que pueden ser definidos para optimizar el almacenamiento en memoria de la data (noten que no todas las entradas de las matrices están siendo guardadas) y de reaccionar a funciones que puedan ser implementadas con mayor facilidad en cierto tipo de matriz (ejemplo: invertir o sacar una determinante de matrices triangulares)

Por ahora, hablemos de los fundamentos de la jerarquía de tipos primitivos:"

# ╔═╡ 54e30a79-701f-44a2-bc79-1a6154b50151
md"
### Jararquía de tipos
Realmente tipos como `Integer` y `AbstractFloat` son lo que se conoce como 'tipos abstractos' en el sentido que no existe explícita una forma de representarlos en una computadora (es decir, carecen de un sistema de representación en bits) pero que es útil definirlos para emparejar con nuestra intuición conceptual y generar una relación jerárquica entre varios tipos concretos como la siguiente:
"

# ╔═╡ f68bbef6-fc0b-463e-8f27-1dcfaddd8261
md"
![diagrama_tipos](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Julia-number-type-hierarchy.svg/1920px-Julia-number-type-hierarchy.svg.png)
Fig 1. Diagrama jarárquico del tipo `Number`.
"

# ╔═╡ 45b819f6-61ca-473f-9c8e-65c49988b7cf
md"
Esto permite tener nociones de *subtipos* de un tipo dado o *supertipos* de un tipo dado.
"

# ╔═╡ ed5360de-50cf-445f-ad3d-13202fd594b1
supertypes(Char)

# ╔═╡ 7c1f03c9-b1a6-4170-b565-a4fdbadc9486
supertypes(Int32)

# ╔═╡ 12e9cb34-e80f-447e-8435-0ad61a8ef83d
supertypes(Function)

# ╔═╡ be6cb995-5edd-446a-8eb3-5115c0276ff4
subtypes(Integer)

# ╔═╡ abeca67b-b061-4497-9847-ef808a739bae
subtypes(Number)

# ╔═╡ 0f154f87-b178-4c64-8960-81b77c6122d2
md"Por encima de todos los tipos definidos en Julia tenemos al tipo global, `Any`. Podemos inspeccionar todos los subtipos inmediatos de `Any`:"

# ╔═╡ b6e48a51-a158-4432-926c-ce9c9726a38c
subtypes(Any)

# ╔═╡ 5180b5e4-58e1-450f-b1ea-4a1ade1ce5b2
md"Como podemos ver, es una gran cantidad de tipos (en general abstractos) que yacen inmediatamente por debajo de `Any`. Intentemos tomar uno de ellos:"

# ╔═╡ 5d4c3f54-bac3-46d9-9e55-24da7996845d
subtypes(AbstractString) # Podemos checar el Live docs de Pluto.

# ╔═╡ f1d7e13b-1c44-4f75-b39f-06909f19ad11
md"Esto delata que el gran poder de expresión de Julia viene de que su sistema de tipos junto con Multiple Dispatch permite que una sola función (cuyo nombre realmente es *función genérica*) es capaz de tomar comportamientos acorde a contexto, tal cual como muchos símbolos en nuestro día a día toman distinto significado dependiendo del contexto: 

*Está más cerca de la mente humana que de la máquina, sin sacrificar la eficiencia al hablarle a la máquina*

Utilicemos un poco los tipos primitivos para familiarizarnos. Podemos construir tipos concretos con sus **constructores** explícitos:
"

# ╔═╡ bfa230b2-dd27-4872-87c3-5b9c3c66a0d2
Float32(4)

# ╔═╡ 6a2bd6f0-36f9-4b1b-bae1-44aa4bab2165
 Float16(4)

# ╔═╡ 2ed6ca54-6d04-4d62-b45d-0ef148998c84
md"Podemos obtener su representación de bits a nivel del computador:"

# ╔═╡ 2fe29d79-07a9-4de3-ba30-ed8a867db724
bitstring(Float32(4.0)) 

# ╔═╡ fd20da9b-3ad6-4687-a277-3d0d8ee60ed9
bitstring(Float16(4.0))

# ╔═╡ e51e9c46-c19d-4e52-9172-cb33fcc20b8b
md"y podemos verificar que ha funcionado viendo su tipo:"

# ╔═╡ df36635f-e493-46c5-95e7-dfbde68e2737
typeof.(Any[Float64(4.0), Float32(4), Float16(4.0), 4.0, Real(4.0)])

# ╔═╡ 680af6e5-9ccf-402d-8e2a-b29f8a648858
md"Notemos algunas cosas:

1. El número `4.0` sin constructor explícito es tipo `Float64`, al menos en la computadora original donde ha sido escrito este cuaderno. Esto es porque mi computadora tiene [**tamaño de palabra**](https://en.wikipedia.org/wiki/Word_(computer_architecture)) igual a 64 bits, al tener el procesador una arquitectura basada en eso.
2. El tipo `Real(4.0)` resultó ser de tipo `Float64`. Esto es porque `Real` es un tipo abstracto que no tiene representación en forma de bits *a priori* y debe ser *aterrizado* a un tipo concreto acorde al contexto del primer momento en que se necesite su representación (este es uno de los aspectos *JIT* del compilador de Julia). 
3. No necesitamos meter `4.0` dentro del constructor de un flotante, puesto que si ponemos el entero `4`, Julia internamente decide **convertir** (técnicamente **promover**) el entero a un flotante dentro del constructor.

Esto mismo le estaría pasando a la lista `[Float64(4.0), Float32(4), Float16(4.0), 4.0, Real(4.0)]` si no se antepusiese un `Any` antes de ello. Observemos:"

# ╔═╡ 6b28f7ce-f39f-4ccf-9ab3-2a5bb1d2ae92
typeof.([Float64(4.0), Float32(4), Float16(4.0), 4.0, Real(4.0)])

# ╔═╡ ed5b13c7-21ba-469d-af43-5cbf91a9070e
md"En este caso, aunque hemos construido algunos flotantes de menor número de bits que 64, al colocarlos dentro es brackets, `[]`, Julia decide transformarlos todos a `Float64`. 

Este es el mismo fenómeno observado anterior mente: **promoción**. Si el compilador de Julia observa que un tipo puede ser transformado, sin perder información, hacia otro y eso mejora el rendimiento, lo hará.

Esta es una declaración ambigüa todavía: ¿Qué significa 'mejorar el rendimiento'? En este caso, los **arreglos** en Julia (conocidos como listas en Python) mejoran su velocidad de lectura y manipulación si todos sus elementos son de un mismo tipo, por lo que Julia automáticamente buscará que así sea si es posible mediante **promoción** de los tipos hacia un tipo en común.

Examinemos de hecho:"

# ╔═╡ ab598a91-b400-4618-8afd-ec65304c9deb
typeof([4, 4.0, 2])

# ╔═╡ 41a5f347-2faf-4833-b79b-f963cd6c3acd
md"Notamos el nombre `Vector{Float64}` y `Array{Float64, 1}`. Estos son conocidos como **tipos compuestos** y, a diferencia de los tipos primitivos, estos se componen de partes de otros tipos (ya sean primitivos u otros compuestos).

Nosotros podemos forzar el tipo de los elementos de un arreglo:"

# ╔═╡ 115b4401-964c-4901-8539-ed5c9537856d
typeof(Float32[4, 4.0, 2])

# ╔═╡ a287fad8-f299-47d1-b0a9-69e3c8dfbd45
md"Podemos verificar que cada elemento individual es efectivamente de tipo `Float32`:"

# ╔═╡ 5575dec3-019e-4289-82af-d344a6272daa
md"
Ya que mencionamos a los arreglos, hablemos ahora un poco de los tipos compuestos.

## Tipos compuestos

Los **tipos compuestos** son tipos en Julia que consisten de elementos de tipos primitivos organizados de alguna manera. Esto quiere decir que su almacenamiento en memoria es equivalente a hablar del almacenamiento en memoria de los tipos primitivos que le conforman. 

Para entender mejor esto, intentemos definir nuestros propios tipos. Estos se definen con la palabra clave `struct`.

### Structs

Los `structs` pueden ser pensados como contenedores de múltiples variables:

"

# ╔═╡ 32c5efdd-fa3c-444a-9fde-2c4f0eb05c81
struct Punto
	x::Float64
	y::Float64
end

# ╔═╡ fa3e55e3-4108-4375-9c41-7883e56d5e35
Punto(1,3)

# ╔═╡ e5fee360-a032-47f0-982a-d25f2967a275
md"En este caso hemos creado un nuevo tipo, `Punto`, que internamente es representado como un par de números `Float64`. Notemos que el constructor de nuevo automáticamente es capaz de promocionar los enteros a flotantes como es requerido.

Los `structs`, sin embargo, no necesitan que se les especifique el tipo de dato de sus atributos:"

# ╔═╡ 3a83c2ec-a5b2-4262-a6af-c2b551eb5ad5
struct Mitipo
	x
	y
end

# ╔═╡ 67bec5e3-ac68-4038-8ae0-2b36ae4ad79e
Mitipo(1,"hola")

# ╔═╡ d169ed1a-2f83-4940-a5ed-9877b8e015ac
md"En este caso `x`, `y` son variables de tipo `Any` y pueden por ende contener cualquier variable de otro tipo que le queramos poner.

Esto se puede ver en acción más particular en el siguiente ejemplo:"

# ╔═╡ bfc51c9e-6af5-4129-b307-c9cc2dd7f781
struct PuntoGeneral
	x::Number
	y::Integer
end

# ╔═╡ 040ba33e-da47-43d0-8c77-ae1b478ff37e
PuntoGeneral(3,2)

# ╔═╡ e67108e6-addf-4c17-b02a-fc0c53c86c8e
PuntoGeneral(3.0,2)

# ╔═╡ e876aa4b-6994-49b0-ae24-1a27ef11e175
PuntoGeneral(3.0,2.0)

# ╔═╡ 5c09c313-2506-48f7-b080-8f162f4936f6
md"Observemos que como definimos a `x` y `y` como tipos abstractos, la primera entrada permite tanto enteros como flotantes sin tener que convertirlo como en el caso anterior. Por otro lado, la segunda entrada solo permite enteros (de cualquier tipo de entero pero no flotante...)

En este caso el constructor pudo convertir el flotante `2.0` a `2` sin problema, pero notemos el siguiente error:"

# ╔═╡ 08a2811a-ddb3-4d7f-bfcf-af5c107381ce
PuntoGeneral(3, 2.1)

# ╔═╡ 768f11d1-b5a7-4f4b-ad27-24010bb8ecb9
md"Esto nos da la flexibilidad pero también el poder de restringir a nuestro gusto de diseñó los tipos de dato primitivo que permitiremos en nuestros tipos propios.

Sigamos con el ejemplo del punto. Podemos crear funciones específicas para nuestro nuevo tipo:"

# ╔═╡ 114a3537-9f0a-4b64-ab41-dcbf321e568a
origen = Punto(0,0); punto_de_interés = Punto(1,1);

# ╔═╡ b4397ac5-f9a1-49b4-96de-c86820c758fa
md"Como vimos antes, también podemos extender el significado de funciones existentes:"

# ╔═╡ 8825f6b5-2872-4e20-a596-d6b7e48fe556
begin
	import Base: +
	+(p₁::Punto, p₂::Punto) = Punto(p₁.x + p₂.x, p₁.y + p₂.y)
end

# ╔═╡ 0479a5b1-24cd-4b13-9678-971a836958cc
f(x) = √x + 4/x - 1

# ╔═╡ b713078d-a7bb-4480-99fb-46fb7ec832d6
g(x) = x^2 + 2x + 1

# ╔═╡ f3c12d40-dd4d-49e3-b066-343cc73daa5d
f(4), g(1)

# ╔═╡ d4e29f9d-176c-4ed7-a430-74663a4ecbd4
typeof(f(4)), typeof(g(1))

# ╔═╡ 84b3d7d0-a392-430c-b227-9a2dae6153fa
typeof.([f(4), g(1)])

# ╔═╡ 458141da-e6aa-4ebe-b855-22d6575def60
plot(g)

# ╔═╡ 0458d39f-6920-4939-bf1f-143de4283427
begin
	plot(f, 0.2:0.01:3, label = "f(x)");
	plot!(g, 0.2:0.01:3, label = "g(x)");
	xlabel!("eje x");
	title!("Mi primer gráfico")
end

# ╔═╡ 9eb0d2d8-5b1a-41e0-aebf-7af779bf50c4
h(x) = x + 1

# ╔═╡ 88528875-d36b-4524-a748-d673bad8fa36
(2*h)(4), (h*2)(4), (h*f)(4)

# ╔═╡ 579cdcf0-3c7e-49cd-ba0b-f83913ca77d8
begin
	foo() = "Sin argumentos"
	foo(x::Int) = x
	foo(x::Int32) = -x
	foo(S::String) = length(S)
	foo(x::Int, S::String) = "¿Aparece $(x) en $(S)? $(occursin(repr(x),S))"
	foo(x::Float64,y::Float64) = sqrt(x^2+y^2)
	foo(a::Any,b::String)= "Mi primer argumento es más general que un entero"
end

# ╔═╡ 85785805-5f24-4541-9dbb-45f487c8dd41
foo(3, "2043")

# ╔═╡ 3d1a0428-1f53-4405-872a-b049368ffe62
foo(3.0, "2043")

# ╔═╡ eb4859ea-b345-4016-9fce-52ac7e0c1219
foo(3), foo(Int32(3)), foo()

# ╔═╡ 75a8f592-8e59-424e-af24-6cae247996ab
d(p₁::Punto, p₂::Punto) = sqrt((p₁.x - p₂.x)^2 + (p₁.y - p₂.y)^2)

# ╔═╡ aca33369-1d46-4e8b-965d-87779151aac5
d(origen, punto_de_interés)

# ╔═╡ 5c1e937a-779d-457e-88eb-6ab61d03fc21
punto_de_interés + punto_de_interés 

# ╔═╡ 0debc89e-6623-47cb-9d7a-5f819f8ca5ff
md"E incluso extender funcionalidad de paquetes importados"

# ╔═╡ 96b3f7ce-fa4a-4ad8-a708-d9d6092b0047
scatter(puntos::Vector{Punto}) = Plots.scatter([(punto.x,punto.y) 
		                                    for punto in puntos], 
	                                        markersize = 8)

# ╔═╡ c0e7757f-5a70-45be-a959-b2e5eb971370
scatter([punto_de_interés, origen])

# ╔═╡ 129972fa-0c56-4191-aaeb-f2bbc153c31b
md"Aunque en el caso de `Plots` (y otros paquetes), los diseñadores de los paquetes se esmeran en exponer formas más sofisticadas (con finalidad de ser más simples pero poderosas) de expandir sus funciones. Un ejemplo son las [recetas de `Plots`](https://docs.juliaplots.org/latest/recipes/), las cuales permiten definir formas de generar gráficos de nuestros tipos propios sin necesitar importar del paquete `Plots` mismo.

Notemos que en la definición de nuestro `plot` hemos dicho que `puntos` es de tipo `vector{Float64}`. Lo que eso significa es que el tipo `vector` es un tipo compuesto que depende de **forma paramétrica** de `Float64`.

Podemos tener dependencias más complejas como:"

# ╔═╡ 5d174192-0b41-40ad-b9d1-abc096ab4573
typeof([(1.0, 4), (2.0, 6), (3.0, -1)])

# ╔═╡ d56213e8-0862-47e1-b142-2c7272d5548c
md"Notemos que Julia siempre elegirá la forma más eficiente para almacenar los datos de nuestros tipos compuestos sin comprometer posible estructura que deseemos o sea conveniente de  tener para uso futuro. 

En este caso, ha detectado el patrón de que siempre la segunda entrada es un `Int64` a pesar de poder haber decidido promoverlo a un `Float64` para tener `Vector{Tuple{Float64, Float64}}`.

La decisión que un lenguaje toma en torno a la promoción e interacción de tipos compuestos está ligada con la noción de [contravarianza y varianza de tipos](https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)).

Observemos qué pasa si una de las entradas es un flotante pero las demás siguen siendo enteras:"

# ╔═╡ 6852539b-b0c1-4c97-87c1-ba664a0dc7d2
# typeof([(1.0, 4), (2.0, 6), (3.0, -1.0)])

# ╔═╡ 33f45a7f-b52a-4d30-9c7e-69948755e90e
md"
## Programación estructurada

Finalmente, estudiaremos de manera breve algunas estructuras de datos comunes en Julia (como la anteriormente utilizada tupla, `Tuple`) junto con estructuras de flujo que juntas conforman lo que conocemos como programación estructurada.

### Booleanos y condicionales"

# ╔═╡ 0be7f348-8668-44b6-8b39-c82f521a7cd0
50 > 3, 0 ≤ 0, 50 + eps() ≈ 50, !true, false || false

# ╔═╡ 4954217a-2512-4f1f-bb87-9fade8063439
md"Podemos utilizar variables booleanas como las anteriores para decidir el flujo de evolución de nuestro código utilizando condicionales:"

# ╔═╡ 8264168c-5ddf-45e5-8a89-700b63e212e0
md" edad = $(@bind edad Slider(1:80, show_value = true))"

# ╔═╡ a36a416e-9dda-47d7-be69-5fbc00f02cd8
if edad > 60
	md"Ciudadano de la tercera edad."
elseif edad > 18
	md"¡Es un ciudadano!"
else
	md"Es menor de edad."
end

# ╔═╡ dfeca1e7-09b9-4146-be2e-d8cf098d2a04
md"### Ciclos de repetición

Los ciclos de repetición se utilizan para poder ejecutar una serie de instrucciones que pueden ser resumidas en una estructura en común y dependa solamente de alguna variable o variables de control o de estado que se actualicen entre iteraciones.

A diferencia de en otros lenguajes, los ciclos de repetición en Julia son igual de veloces que hacer cálculos vectorizados, por lo que no debería significar ninguna molestia definir ciclos:"

# ╔═╡ 44d1d353-447b-4550-b95c-58cc64509c55
let z = []
	for i ∈ 1:3
		for j in 3:-1:1
			push!(z, (i,j))
		end
	end
	z
end

# ╔═╡ 2a0b9b7f-b345-4866-a16e-21f74367dbc2
md"Notemos además que el tipo de la tupla es `Any` a pesar de que contiene solamente tuplas de dos enteros. Esto es porque, al momento inicial donde estamos definiendo a `z`, el compilador no tenía información del ciclo venidero y por ende de lo que podía estar dentro de la sentencia `push!`. 

Como podíamos, en principio, añadir elementos de cualquier tipo, el almacenamiento de la variable `z` se volvió lo más general posible. Este es un punto fuerte para el cómputo de algo rendimiento: **Definir correctamente los tipos si sabemos de antemano qué serán**:"

# ╔═╡ 8f764674-62a5-4cfc-8b1d-d760c13a0b14
let z = Tuple{Int64, Int64}[]
	for i ∈ 1:3
		j = 3
		while j > 0
			push!(z, (i,j))
			j -= 1
		end
	end
	z
end

# ╔═╡ bb0b04e9-b147-4e39-abb2-be66680404bd
md"En esta ocasión ya tenemos que `z` es un tipo concreto que será representado de manera mucho más compacta en memoria e identificado útilmente para uso en funciones."

# ╔═╡ d9dd4da8-3fff-4830-afd1-e99fd2f2db58
md"### Estructuras varias de datos"

# ╔═╡ 9a0283dd-3330-4ead-8908-2c8599454954
typeof.([
		(1,2,4),
		[1,4,2],
		[1 4 2],
		[1;4;2],         # Un vector columna.
		[1 4 2; 4 2 1],  # Cada ; denota salto a siguiente fila
		Dict("1" => 1, "2" => 4),
		Dict(:primera => Dict((1,3) => 1.04), :segunda => Dict((-1, 2) => 0.0)),
		5 => 1,
		(),              # Tupla sin inicializar. Como las tuplas son inmutables...
		[],              # Pero los vectores/arreglos no lo son.
		1+4im,
		π,
		5//2,
		Inf
	])

# ╔═╡ b0c7c778-7bc5-4faf-8769-0ab9cb64f440
md"¿Cuál creen que es el resultado de lo siguiente?"

# ╔═╡ b6bc7752-5e16-4263-ae50-2b5f774b5403
#typeof(Dict(:primera => Dict((1,3) => 1.04), :segunda => Dict((-1, 2.0) => 0.0)))

# ╔═╡ 4f7e3a91-b45f-44a1-b590-f260f45ea151
md"Esto nos lleva a lo último de esta sección: Parámetros libres en Structs:"

# ╔═╡ 7fe38486-0e07-4c25-9e2a-328d2e127268
struct tipo_paramétrico{T <: Integer}
	x::T
	y::T
end

# ╔═╡ 12d29af6-73b7-4d38-9d09-8bd9abe3439a
tipo_paramétrico(1,3)

# ╔═╡ 92e1a00f-c8fc-4d7e-9c3b-7f5f46e3d470
tipo_paramétrico(1.0,3)

# ╔═╡ 94619f75-02cb-4234-941c-516ff8cf70a6
macro seeprints(expr)
	quote
		stdout_bk = stdout
		rd, wr = redirect_stdout()
		$expr
		redirect_stdout(stdout_bk)
		close(wr)
		read(rd, String) |> Text
	end
end;

# ╔═╡ 3d7ae470-c088-4efe-9b69-7ba256d651cf
@seeprints for i ∈ Float32[4, 4.0, 2]
	println(typeof(i))
end

# ╔═╡ Cell order:
# ╠═98ab1365-b894-4789-85e2-5b36ab05593c
# ╟─c4ad90dc-b5f0-11eb-0fcf-c75235c9ff14
# ╠═0479a5b1-24cd-4b13-9678-971a836958cc
# ╠═b713078d-a7bb-4480-99fb-46fb7ec832d6
# ╟─0d213fe4-7134-4b29-ac25-e9040bec6f28
# ╠═f3c12d40-dd4d-49e3-b066-343cc73daa5d
# ╟─6aeed4ab-aa87-4d77-a006-76faa391bceb
# ╠═d4e29f9d-176c-4ed7-a430-74663a4ecbd4
# ╟─88236333-85b1-4ef5-ae74-d67e94f74f9b
# ╠═84b3d7d0-a392-430c-b227-9a2dae6153fa
# ╟─b77774cd-f370-423e-9155-9b91f67e1622
# ╠═458141da-e6aa-4ebe-b855-22d6575def60
# ╟─bfb35ee8-163f-422e-bffe-f533beafd78c
# ╠═0458d39f-6920-4939-bf1f-143de4283427
# ╟─18c42908-e4e1-4e1b-af86-d4a46da837ef
# ╠═c41fd8d5-ed76-4bc1-86c2-8a7f1661168c
# ╟─75b26f6d-1223-4bab-bbde-94f879aa8b07
# ╠═9eb0d2d8-5b1a-41e0-aebf-7af779bf50c4
# ╠═88528875-d36b-4524-a748-d673bad8fa36
# ╟─b66189d7-4d81-4bd5-ae45-70368c519340
# ╠═579cdcf0-3c7e-49cd-ba0b-f83913ca77d8
# ╠═85785805-5f24-4541-9dbb-45f487c8dd41
# ╠═3d1a0428-1f53-4405-872a-b049368ffe62
# ╟─fc857690-684c-41fc-b37e-c8ec02aac3a3
# ╠═eb4859ea-b345-4016-9fce-52ac7e0c1219
# ╟─78244bfc-4bf9-4fcc-b2e6-08fff994365a
# ╠═da26fd9e-992c-48b1-9bef-8dca240529aa
# ╠═c058b5dd-3a6e-42d5-9c2c-a574a04cc11a
# ╟─c91a1ef0-6520-4a30-9c5c-b36fb79cdeeb
# ╠═13e0a04c-03f5-44ef-b7dd-7679743f4bfa
# ╠═5c4c1ceb-38b4-43ed-837c-21ba34bb56af
# ╟─d3822674-f3c4-4066-9227-c8af13a3e005
# ╟─54e30a79-701f-44a2-bc79-1a6154b50151
# ╟─f68bbef6-fc0b-463e-8f27-1dcfaddd8261
# ╟─45b819f6-61ca-473f-9c8e-65c49988b7cf
# ╠═ed5360de-50cf-445f-ad3d-13202fd594b1
# ╠═7c1f03c9-b1a6-4170-b565-a4fdbadc9486
# ╠═12e9cb34-e80f-447e-8435-0ad61a8ef83d
# ╠═be6cb995-5edd-446a-8eb3-5115c0276ff4
# ╠═abeca67b-b061-4497-9847-ef808a739bae
# ╟─0f154f87-b178-4c64-8960-81b77c6122d2
# ╠═b6e48a51-a158-4432-926c-ce9c9726a38c
# ╟─5180b5e4-58e1-450f-b1ea-4a1ade1ce5b2
# ╠═5d4c3f54-bac3-46d9-9e55-24da7996845d
# ╟─f1d7e13b-1c44-4f75-b39f-06909f19ad11
# ╠═bfa230b2-dd27-4872-87c3-5b9c3c66a0d2
# ╠═6a2bd6f0-36f9-4b1b-bae1-44aa4bab2165
# ╟─2ed6ca54-6d04-4d62-b45d-0ef148998c84
# ╠═2fe29d79-07a9-4de3-ba30-ed8a867db724
# ╠═fd20da9b-3ad6-4687-a277-3d0d8ee60ed9
# ╟─e51e9c46-c19d-4e52-9172-cb33fcc20b8b
# ╠═df36635f-e493-46c5-95e7-dfbde68e2737
# ╟─680af6e5-9ccf-402d-8e2a-b29f8a648858
# ╠═6b28f7ce-f39f-4ccf-9ab3-2a5bb1d2ae92
# ╟─ed5b13c7-21ba-469d-af43-5cbf91a9070e
# ╠═ab598a91-b400-4618-8afd-ec65304c9deb
# ╟─41a5f347-2faf-4833-b79b-f963cd6c3acd
# ╠═115b4401-964c-4901-8539-ed5c9537856d
# ╟─a287fad8-f299-47d1-b0a9-69e3c8dfbd45
# ╠═3d7ae470-c088-4efe-9b69-7ba256d651cf
# ╟─5575dec3-019e-4289-82af-d344a6272daa
# ╠═32c5efdd-fa3c-444a-9fde-2c4f0eb05c81
# ╠═fa3e55e3-4108-4375-9c41-7883e56d5e35
# ╟─e5fee360-a032-47f0-982a-d25f2967a275
# ╠═3a83c2ec-a5b2-4262-a6af-c2b551eb5ad5
# ╠═67bec5e3-ac68-4038-8ae0-2b36ae4ad79e
# ╟─d169ed1a-2f83-4940-a5ed-9877b8e015ac
# ╠═bfc51c9e-6af5-4129-b307-c9cc2dd7f781
# ╠═040ba33e-da47-43d0-8c77-ae1b478ff37e
# ╠═e67108e6-addf-4c17-b02a-fc0c53c86c8e
# ╠═e876aa4b-6994-49b0-ae24-1a27ef11e175
# ╟─5c09c313-2506-48f7-b080-8f162f4936f6
# ╠═08a2811a-ddb3-4d7f-bfcf-af5c107381ce
# ╟─768f11d1-b5a7-4f4b-ad27-24010bb8ecb9
# ╠═75a8f592-8e59-424e-af24-6cae247996ab
# ╠═114a3537-9f0a-4b64-ab41-dcbf321e568a
# ╠═aca33369-1d46-4e8b-965d-87779151aac5
# ╟─b4397ac5-f9a1-49b4-96de-c86820c758fa
# ╠═8825f6b5-2872-4e20-a596-d6b7e48fe556
# ╠═5c1e937a-779d-457e-88eb-6ab61d03fc21
# ╟─0debc89e-6623-47cb-9d7a-5f819f8ca5ff
# ╠═96b3f7ce-fa4a-4ad8-a708-d9d6092b0047
# ╠═c0e7757f-5a70-45be-a959-b2e5eb971370
# ╟─129972fa-0c56-4191-aaeb-f2bbc153c31b
# ╠═5d174192-0b41-40ad-b9d1-abc096ab4573
# ╠═d56213e8-0862-47e1-b142-2c7272d5548c
# ╠═6852539b-b0c1-4c97-87c1-ba664a0dc7d2
# ╟─33f45a7f-b52a-4d30-9c7e-69948755e90e
# ╠═0be7f348-8668-44b6-8b39-c82f521a7cd0
# ╟─4954217a-2512-4f1f-bb87-9fade8063439
# ╟─8264168c-5ddf-45e5-8a89-700b63e212e0
# ╠═a36a416e-9dda-47d7-be69-5fbc00f02cd8
# ╟─dfeca1e7-09b9-4146-be2e-d8cf098d2a04
# ╠═44d1d353-447b-4550-b95c-58cc64509c55
# ╟─2a0b9b7f-b345-4866-a16e-21f74367dbc2
# ╠═8f764674-62a5-4cfc-8b1d-d760c13a0b14
# ╟─bb0b04e9-b147-4e39-abb2-be66680404bd
# ╟─d9dd4da8-3fff-4830-afd1-e99fd2f2db58
# ╠═9a0283dd-3330-4ead-8908-2c8599454954
# ╟─b0c7c778-7bc5-4faf-8769-0ab9cb64f440
# ╠═b6bc7752-5e16-4263-ae50-2b5f774b5403
# ╟─4f7e3a91-b45f-44a1-b590-f260f45ea151
# ╠═7fe38486-0e07-4c25-9e2a-328d2e127268
# ╠═12d29af6-73b7-4d38-9d09-8bd9abe3439a
# ╠═92e1a00f-c8fc-4d7e-9c3b-7f5f46e3d470
# ╟─94619f75-02cb-4234-941c-516ff8cf70a6
