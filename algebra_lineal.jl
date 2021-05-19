### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ abe7fd9e-b7a3-11eb-1e21-a5d1fe2d95cd
begin
	using Pkg; Pkg.activate("..")
	using LinearAlgebra, OffsetArrays, DifferentialEquations, StaticArrays, Plots
end

# ╔═╡ 9a3bf8cf-1193-47c9-82b4-80feda18c240
md"# Fundamentos de vectores, matrices y arreglos generales en Julia

Cuando estamos trabajando con arreglos en general, especialmente si tenemos más indices que solamente 2 (lo que algunos llamarían tensor, aunque es estrictamente un tensor junto con una elección de base) es conveniente utilizar el objeto de Julia llamado `CartesianIndex`:"

# ╔═╡ 4cd67fbc-a7c7-4f79-a76d-7e81f159fe45
A = rand(5,4)

# ╔═╡ 9c35b8ec-f4db-4ecb-865f-d63c9411b8a2
I = CartesianIndices(A)

# ╔═╡ 1b92242a-696f-4ce2-96ce-aac204bcd7b3
md"De esa manera podemos tener un solo conjunto $I$ de índices para iterar a lo largo de nuestra matriz:"

# ╔═╡ 597e92a0-e5d9-49dc-94be-104e79bbe4a8
begin
	z = 0
	for i ∈ I
		z += A[i]
	end
	z
end

# ╔═╡ 84686497-1456-4e04-ba1f-12887cd4cee8
md"También podemos hacer operaciones convenientes muy comúnmente necesitadas en métodos numéricos como:"

# ╔═╡ 6efe7f40-ab78-4328-becd-ab25b3481b13
A_con_frontera = OffsetArray(zeros(7,6), 0:6, 0:5)

# ╔═╡ 46bef35d-706d-42af-a77a-49797dc37afc
A_con_frontera[I] .= A[I]; 

# ╔═╡ d09a47b9-497b-42b9-a00e-091a0b761bb2
A_con_frontera

# ╔═╡ 767f1e31-c77d-4c2c-bb38-8ee9213b6d6a
md"Esta matriz con una frontera llena de ceros puede perfectamente representar la matriz resultante de la discretización de algún operador diferencial en una ecuación diferencial parcial con condición de frontera de Dirichlet.

Discutamos lo que ha sucedido arriba en mayor detalle:
- Se ha utilizado un objeto nuevo llamado `OffsetArray`. Es un tipo de arreglo especial que nos permite indicar el rango de índices que queremos tener, para poder iniciar de algún índice que comience del usual 1 en Julia.
- Se ha utilizado el `.` para realizar broadcasting con la asignación para asignar en una solalinea todas las entradas de `A[I]` en la submatriz correspondiente `A_con_frontera[I]`.

  Recordemos que el conjunto `I` contiene todos los índices de `A`.

Discutamos algunas funciones especiales que vienen en el paquete de álgebra lineal.

## Funciones de álgebra lineal

"

# ╔═╡ f0ce3d18-56b6-4437-bb15-46844cb6158e
B = [1 4; -4 7]

# ╔═╡ eefd0611-d4f5-4265-8fc9-dac27f0e5a96
eigen(B)

# ╔═╡ 2706a4d3-8a9c-4000-a89f-dd49d1121e41
eigvals(B)

# ╔═╡ bd3fd751-51f3-4bdc-a297-a874c089f461
eigvecs(B)

# ╔═╡ abe09d2f-12f3-4af7-97a5-330c7288067a
svd(B)

# ╔═╡ 240df88f-caca-448d-9fa2-eeca29591d13
svdvals(B)

# ╔═╡ f24e5db8-c2e7-4fc1-9a4c-54cb0f73fc96
md"## Factorizaciones"

# ╔═╡ dc2cc4e3-ade1-4b98-9b3e-859bbdf4e97b
result = factorize([1 2 3; 
		   			2 1 4;
		   			3 4 1])

# ╔═╡ 6d280df4-f99a-48af-8f57-a65408733a5b
result.D, result.U

# ╔═╡ 01d90460-3e53-4ee7-be7b-5e7158a8f49f
C = [1 2 3; 
     2 1 4;
     3 4 1]

# ╔═╡ 36837046-a659-4429-a27e-6cef896fb0bd
qr(C)

# ╔═╡ fa6695a8-5f7c-41e4-bdd7-99754fa577da
lu(C)

# ╔═╡ 5194a7de-3f5b-466b-bafd-2bf1f864086c
ldlt(SymTridiagonal([3., 4., 5.], [1., 2.]))

# ╔═╡ 2ba5ea70-d73e-4422-a7b0-ba132278105e
schur(C)

# ╔═╡ e3e1b784-192e-49fb-9aa4-a8a7f3620a9d
md"
## Arreglos estáticos
Los arreglos estáticos son una estructura de dato crucial de comprender para el eficiente almacenamiento de la información. Para comprenderlo un poco mejor, observemos el siguiente diagrama:

![memory_management](https://visualgdb.com/w/wp-content/uploads/2021/02/stack-1.png)

Los arreglos en lenguajes dinámicos como Julia, aunque puedan ser optimizados en la forma de almacenarse cuando se inicializan, deben ser guardados en una región específica (entre las arriba mostradas) de la memoria reservada para el proceso (en este caso el proceso que el REPL/Pluto representa). Esta es el **heap**, donde existen todas las variables que pueden ser modificadas en **run-time** o tiempo de corrida y su tamaño total es variable.

Esto es porque nada nos detiene de insertar nuevos elementos o cambiar los existentes y el compilador de Julia no puede asumir que no lo haremos. Esto es, a menos que decidamos comunicarle desde un inicio que no será así.

Esto es lo que los arreglos especiales, llamados `StaticArrays`, resuelven. Éstos arrelos estáticos se almacenan en el **stack**, que es un segmento de la memoria reservada para el proceso y de tamaño fijado en el tiempo de compilación. 

Mirémolos en acción simultaneamente a la resolución de un sistema de ecuaciones diferenciales para luego explicarlo por etapas:"

# ╔═╡ 1c4e686c-ae74-424c-b594-b843e1fae44a
md"En la anterior celda hemos utilizado funciones del paquete `DifferentialEquations` que forma parte del ecosistema de machine learning científico, `SciML`. 

Para poder tener un mejor entendimiento de los pasos de resolución de una ecuación diferencial, consideremos la siguiente

$g(u(t)) = \alpha u(t)$

donde $\alpha \in \mathbb{R}$ y $u:\mathbb{R} \rightarrow \mathbb{R}$ es una función incógnita que puede ser encontrada con técnicas derivadas del cálculo y que confirman el aspecto teórico del campo de las **ecuaciones diferenciales**.

En este caso, exploraremos cómo resolverla numéricamente, sin necesitar entrar en mayor detalle, utilizando el paquete `DifferentialEquations`. 

El primer paso para ello es definir la función:
"

# ╔═╡ bcab708e-ca1e-4d27-9d14-ccd306817dc1
g(u,p,t) = 1.01*u

# ╔═╡ be297459-6aa0-4ee8-b8e9-3752988c3399
md"Resulta que esta ecuación diferencial tiene infinitas soluciones si contásemos traslaciones de su condición inicial (el donde donde $t=0$, es decir, $u(0)$, el cual es arbitrariamente selecto para servir como un parámetro fijador de qué solución seleccionar entre las infinitas.

Imaginemos que $u(0) = 1/2$"

# ╔═╡ d1d45d17-9cd0-4fed-9411-cf1f793d929e
u₀ = 1/2

# ╔═╡ c080b0f3-8292-4dd6-a4ac-878fb315bd49
md"Además, de manera teórica, podemos encontrar/verificar una función que cumpla ser solución de la ecuación diferencial para todo tiempo, no obstante, en una computadora no podemos representar una cantidad infinita de puntos, por lo que debemos definir un rango de tiempos en el cual vamos a querer resolver:"

# ╔═╡ 51ae2860-27d3-435f-ac29-0a64a96904cf
tspan = (0.0,1.0)

# ╔═╡ cc65b649-ad3d-4e6f-b021-f38fc74c7fc0
begin
	let M  = @SMatrix [ 1.0  0.0 0.0 -5.0
	              	    4.0 -2.0 4.0 -3.0
	            	   -4.0  0.0 0.0  1.0
	              	    5.0 -2.0 2.0  3.0]
	u0 = @SMatrix rand(4,2)
	t_rango = (0.0,1.0)
	f(u,p,t) = M*u
	problema = ODEProblem(f,u0,tspan)
	solución = solve(problema)
	plot(solución)
	end 
end

# ╔═╡ 8db3eff6-cb53-4b0f-8a81-b034ee7aa511
md"Una vez definidas esas condiciones, podemos construir una variable de tipo `ODEProblem` (definido dentro del paquete `DifferentialEquations`) para representar nuestro problema que ahora yace bien planteado."

# ╔═╡ 38b677d7-7bc5-4e5e-8737-b3b8e40a1b5b
prob = ODEProblem(g,u₀,tspan)

# ╔═╡ 5c5c68fb-5aa2-41ac-b2df-cb614f612c64
md"En julia, una vez definido el problema, resolverlo es tan sencillo como escribir `solve`. "

# ╔═╡ 5bc0c8df-a7f8-40e8-b6ab-8fe115487eac
solve(prob)

# ╔═╡ ae7f9524-6440-4edc-9b91-51e45388619c
md"Podemos además especificar algunos parámetros dentro de `solve`, como ser el *solver* utilizado, la tolerancia relativa y tolerancia absoluta:"

# ╔═╡ 36a76335-3862-4850-98ef-4401b4e2ceff
sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

# ╔═╡ 4edac066-c0f2-4ce2-b432-47ef4683501e
md"Intentemos ahora graficar la función solución obtenida de forma analítica y nuestra solución numérica:"

# ╔═╡ 610d9df9-f16b-4678-bc19-7b08469789cb
begin 
	plot(sol,linewidth=5,
		 title="Solución de la función u'(t) = αu(t)",
         xaxis="Tiempo (t)",
		 yaxis="u(t)",
		 label="Solución numérica") 
	
	plot!(sol.t, t->0.5*exp(1.01t),
		  lw=3,
		  ls=:dash,
		  label="Solución analítica")
end

# ╔═╡ Cell order:
# ╠═abe7fd9e-b7a3-11eb-1e21-a5d1fe2d95cd
# ╟─9a3bf8cf-1193-47c9-82b4-80feda18c240
# ╠═4cd67fbc-a7c7-4f79-a76d-7e81f159fe45
# ╠═9c35b8ec-f4db-4ecb-865f-d63c9411b8a2
# ╟─1b92242a-696f-4ce2-96ce-aac204bcd7b3
# ╠═597e92a0-e5d9-49dc-94be-104e79bbe4a8
# ╟─84686497-1456-4e04-ba1f-12887cd4cee8
# ╠═6efe7f40-ab78-4328-becd-ab25b3481b13
# ╠═46bef35d-706d-42af-a77a-49797dc37afc
# ╠═d09a47b9-497b-42b9-a00e-091a0b761bb2
# ╟─767f1e31-c77d-4c2c-bb38-8ee9213b6d6a
# ╠═f0ce3d18-56b6-4437-bb15-46844cb6158e
# ╠═eefd0611-d4f5-4265-8fc9-dac27f0e5a96
# ╠═2706a4d3-8a9c-4000-a89f-dd49d1121e41
# ╠═bd3fd751-51f3-4bdc-a297-a874c089f461
# ╠═abe09d2f-12f3-4af7-97a5-330c7288067a
# ╠═240df88f-caca-448d-9fa2-eeca29591d13
# ╟─f24e5db8-c2e7-4fc1-9a4c-54cb0f73fc96
# ╠═dc2cc4e3-ade1-4b98-9b3e-859bbdf4e97b
# ╠═6d280df4-f99a-48af-8f57-a65408733a5b
# ╠═01d90460-3e53-4ee7-be7b-5e7158a8f49f
# ╠═36837046-a659-4429-a27e-6cef896fb0bd
# ╠═fa6695a8-5f7c-41e4-bdd7-99754fa577da
# ╠═5194a7de-3f5b-466b-bafd-2bf1f864086c
# ╠═2ba5ea70-d73e-4422-a7b0-ba132278105e
# ╟─e3e1b784-192e-49fb-9aa4-a8a7f3620a9d
# ╠═cc65b649-ad3d-4e6f-b021-f38fc74c7fc0
# ╟─1c4e686c-ae74-424c-b594-b843e1fae44a
# ╠═bcab708e-ca1e-4d27-9d14-ccd306817dc1
# ╟─be297459-6aa0-4ee8-b8e9-3752988c3399
# ╠═d1d45d17-9cd0-4fed-9411-cf1f793d929e
# ╟─c080b0f3-8292-4dd6-a4ac-878fb315bd49
# ╠═51ae2860-27d3-435f-ac29-0a64a96904cf
# ╟─8db3eff6-cb53-4b0f-8a81-b034ee7aa511
# ╠═38b677d7-7bc5-4e5e-8737-b3b8e40a1b5b
# ╟─5c5c68fb-5aa2-41ac-b2df-cb614f612c64
# ╠═5bc0c8df-a7f8-40e8-b6ab-8fe115487eac
# ╟─ae7f9524-6440-4edc-9b91-51e45388619c
# ╠═36a76335-3862-4850-98ef-4401b4e2ceff
# ╟─4edac066-c0f2-4ce2-b432-47ef4683501e
# ╠═610d9df9-f16b-4678-bc19-7b08469789cb
