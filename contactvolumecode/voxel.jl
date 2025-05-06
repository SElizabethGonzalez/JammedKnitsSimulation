# written by S. Gonzalez
# last edited April 24 2024


using DelimitedFiles, CSV, DataFrames, Plots

#ydim, xdim, lowest energy init, energy copied from analyzesimdata.nb minEnergy list

ffs = [
	[2.679, 1.91101, 3, 0.436811],
	[2.68, 1.91056, 3, 0.43681],
	[2.69, 1.90755, 4, 0.436905],
	[2.7, 1.90439, 5, 0.437121],
	[2.71, 1.90108, 5, 0.437426],
	[2.72, 1.89756, 3, 0.437795],
	[2.73, 1.89443, 3, 0.43821],
	[2.74, 1.8909, 4, 0.438662],
	[2.75, 1.88747, 3, 0.439145],
	[2.76, 1.88433, 3, 0.439655],
	[2.77, 1.88099, 3, 0.44019],
	[2.78, 1.87735, 3, 0.440746],
	[2.79, 1.87413, 3, 0.441324],
	[2.8, 1.87061, 3, 0.441919],
	[2.81, 1.86735, 3, 0.442536],
	[2.82, 1.86376, 3, 0.443169],
	[2.83, 1.86033, 3, 0.443821],
	[2.84, 1.85691, 3, 0.444488],
	[2.85, 1.85366, 3, 0.445173],
	[2.86, 1.85027, 3, 0.445875],
	[2.87, 1.84669, 3, 0.446592],
	[2.88, 1.84356, 3, 0.447327],
	[2.89, 1.83982, 4, 0.448077],
	[2.9, 1.83644, 3, 0.448842],
	[2.91, 1.83329, 3, 0.449624],
	[2.92, 1.82963, 4, 0.450422],
	[2.93, 1.82618, 3, 0.451235],
	[2.94, 1.82278, 3, 0.452064],
	[2.95, 1.81936, 4, 0.45291],
	[3.05, 1.78515, 4, 0.462241],
	[3.15, 1.75128, 2, 0.473191],
	[3.25, 1.71737, 2, 0.485874],
	[3.35, 1.68326, 3, 0.500393],
	[3.45, 1.64974, 3, 0.516993],
	[3.55, 1.6165, 3, 0.535877],
	[3.65, 1.58315, 3, 0.557321],
	[3.75, 1.54581, 3, 0.58026],
	[3.85, 1.51182, 3, 0.607165],
	[3.95, 1.47876, 3, 0.638674],
	[4.05, 1.44627, 2, 0.676242],
	[4.15, 1.41448, 2, 0.723521],
	[4.25, 1.38186, 2, 0.789977],
	[4.35, 1.34279, 1, 0.914092]
]

t = 0.02
rad = 0.74

output = []

filestr= "10500"


for m in 1:size(ffs,1)
# import the data
	init = string(round(ffs[m][3]))
	ydim = string(ffs[m][1])

	println(ydim)

	folder = "k1len" * filestr * "x/init_" * init[1] * "/xresults_" * ydim * "/"

	file = CSV.read(folder * "YarnShapeOut.csv", DataFrame)

	dims = readdlm(folder * "StretchOut.dat")

	ylength = dims[1]
	llength = length(ylength)
	lengthnoc = ylength[1:(llength-1)]
	ylength = parse(Float64, lengthnoc)

	c = dims[2]
	c = c[1:(length(c)-1)]
	c = parse(Float64,c)

	w = dims[3]

	# put backbone data into an array
	points = []



	for i in 1:size(file,1)
		row=[]
		for j in 1:size(file,2)
			push!(row, Float64(file[i,j]))
		end
		push!(points, row)
	end

	# re-sample so there are less points
	a = collect(0:39)

	b = a.*10
	b[1]=1
	push!(b,399)

	stitchpointsright = []

	for i in 1:size(b,1)
		num = b[i]
		fucky = points[num]
		push!(stitchpointsright, [points[num][1], points[num][2], points[num][3]])
	end

	#make the left side of the stitch
	rightreverse = reverse(stitchpointsright, dims=1)

	stitchpointsleft = []

	for i in 1:size(rightreverse,1)
		push!(stitchpointsleft, [-1*rightreverse[i][1],rightreverse[i][2],rightreverse[i][3]])
	end

	# full stitch
	stitchpoints = vcat(stitchpointsleft, stitchpointsright)


	#make the surrounding stitches
	stitchright = []
	stitchleft = []
	for i in 8:72
		push!(stitchright, [(stitchpoints[i][1] + c), stitchpoints[i][2], stitchpoints[i][3]])
		push!(stitchleft, [(stitchpoints[i][1] - c), stitchpoints[i][2], stitchpoints[i][3]])
	end

	stitchup = []
	stitchdown = []
	stitchup2 = []
	stitchdown2=[]
	for i in 1:size(stitchpoints,1)
		push!(stitchup, [stitchpoints[i][1], (stitchpoints[i][2] + w), stitchpoints[i][3]])
		push!(stitchdown, [stitchpoints[i][1], (stitchpoints[i][2] - w), stitchpoints[i][3]])
		push!(stitchup2, [stitchpoints[i][1], (stitchpoints[i][2] + 2*w), stitchpoints[i][3]])
		push!(stitchdown2, [stitchpoints[i][1], (stitchpoints[i][2] - 2*w), stitchpoints[i][3]])
	end

	otherpoints = vcat(stitchright, stitchleft, stitchup, stitchdown, stitchup2, stitchdown2)

	# find bounds of the spline backbone
	x =[]

	for i in 1:size(stitchpoints,1)
		push!(x, stitchpoints[i][1])
	end

	y =[]

	for i in 1:size(stitchpoints,1)
		push!(y, stitchpoints[i][2])
	end

	z =[]

	for i in 1:size(stitchpoints,1)
		push!(z, stitchpoints[i][3])
	end

	literalbounds =[
		minimum(x),
		minimum(y),
		minimum(z),
		maximum(x),
		maximum(y),
		maximum(z)
	]

	#find bounds of where the yarn is
	bounds = []
	# bounds will be minx maxx miny maxy minz maxz even though literal bounds isn't
	boundsnumber =[]

	for i in 1:3
		add = t*(round((literalbounds[i]-rad)/t) - 10)
		push!(bounds, add)
		push!(boundsnumber, round(add/t))
		add2 = t*(round((literalbounds[i+3]+rad)/t) + 10)
		push!(bounds, add2)
		push!(boundsnumber, round(add2/t))
	end

	#make the voxel mesh
	meshpoints = []

	for i in boundsnumber[1]:boundsnumber[2]
		for j in boundsnumber[3]:boundsnumber[4]
			for k in boundsnumber[5]:boundsnumber[6]
				push!(meshpoints, [i*t, j*t, k*t])
			end
		end
	end


	function distance(r1::Vector{Float64}, r2::Vector{Float64})
		return sqrt((r1[1] - r2[1])^2 + (r1[2] - r2[2])^2 + (r1[3] - r2[3])^2)
	end


	# only record the voxel points that are within the stitch boundary
	stitchmesh=[]

	for i in 1:size(meshpoints,1)
		for j in 1:82
			if distance(meshpoints[i], stitchpoints[j]) <= rad
				push!(stitchmesh, meshpoints[i])
				break
			end
		end
	end

	voxelsize=t^3
	meshsize=size(stitchmesh,1)*voxelsize
	# println(meshsize)

	# get rid of the end-caps

	rightpoint= stitchpoints[82]
	leftpoint = stitchpoints[1]
	leftfar = rightpoint - [c,0,0]
	rightfar = leftpoint + [c,0,0]

	capindexes=[]

	for i in 1:size(stitchmesh,1)
		if stitchmesh[i][1] > (rightpoint[1]-1.25*rad) && stitchmesh[i][2]<(rightpoint[2]+1.25*rad) && distance(stitchmesh[i], rightpoint) > distance(stitchmesh[i],rightfar)
			push!(capindexes, i)
		end
		if stitchmesh[i][1] > (leftpoint[1]-1.25*rad) && stitchmesh[i][2]<(leftpoint[2]+1.25*rad) && distance(stitchmesh[i], leftpoint) > distance(stitchmesh[i],leftfar)
			push!(capindexes, i)
		end
	end

	deleteat!(stitchmesh, capindexes)

	uncompressedvolume=size(stitchmesh,1)*voxelsize
	# println(uncompressedvolume)


	xpoints=[]
	ypoints=[]
	for i in 1:size(stitchmesh,1)
		push!(xpoints, stitchmesh[i][1])
		push!(ypoints, stitchmesh[i][2])
	end

	# scatter(xpoints,ypoints)
	# savefig("uncompressed.png")

	contacts = []

	for i in 1:size(stitchmesh,1)
		for j in 1:size(otherpoints,1)
			if distance(stitchmesh[i], otherpoints[j]) <= rad
				push!(contacts, stitchmesh[i])
				break
			end
		end
	end

	contactvolume = size(contacts,1)*voxelsize

	compressedvolume = uncompressedvolume - (contactvolume/2)
	# println("stitch volume")
	# println(compressedvolume)


	# cell volume

	zwidthspline = maximum(z) - minimum(z) + 2*rad
	# println(zwidthspline)

	cellvolume = c*w*zwidthspline
	# println("cell volume")
	# println(cellvolume)

	# println("packing fraction")
	# println(compressedvolume/cellvolume)

	foroutput = [ylength, c, w, zwidthspline, compressedvolume, cellvolume, compressedvolume/cellvolume]

	println(foroutput)

	push!(output, foroutput)
end


writedlm("voxeldata0_02tx" * filestr * ".csv", output, ',')
