using OrdinalGWAS, Test, CSV, SnpArrays, DataFrames, VariantCallFormat, GeneticVariantBase, PGENFiles, BGEN, Statistics, VCFTools, Profile, ProfileView, Serialization, PProf
const datadir = joinpath(dirname(@__FILE__), "..", "data")
# datadir = joinpath(dirname(@__FILE__), "data")
const covfile = datadir * "/covariate.txt"
const plkfile = datadir * "/hapmap3"
const snpsetfile = datadir * "/hapmap_snpsetfile.txt"
const vcfcovfile = datadir * "/vcf_example.csv"
const vcffile = datadir * "/vcf_test"
# const vcffile = joinpath(datadir, "vcf_test.vcf.gz")
# const vcffile = "/Users/kaitlyn/.julia/dev/OrdinalGWAS/data/vcf_test.vcf.gz"
const vcfsnpsetfile = datadir * "/snpsetfile_vcf.txt"
const bgencovfile = datadir * "/bgen_ex.csv"
const bgenfile = datadir * "/bgen_test.bgen" #is it fine to change this from bgen_test to bgen_test.bgen
const bgensnpsetfile = datadir * "/bgen_snpsetfile.txt"

const bedfile = datadir * "/hapmap3.bed"
const bimfile = datadir * "/hapmap3.bim"
const pgenfile = PGENFiles.datadir("bgen_example.16bits.pgen")

const dataset= SnpData(datadir * "/hapmap3")


# VCF tests

# ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, geneticrowinds = 1:190, snpinds = [86; 656], 
#     test = :score, covrowinds = 1:190


# 83.442078 seconds (568.26 M allocations: 79.282 GiB, 7.15% gc time, 6.23% compilation time: 5% of which was recompilation)
# 2 GiB

# 0.805710 seconds (15.83 M allocations: 1.004 GiB, 7.72% gc time)


@testset "vcf score test" begin
    # println("Constructed path: ", vcffile)
   
    vcfdata = VCFTools.VCFData(vcffile * ".vcf.gz")
    nsamples = GeneticVariantBase.n_samples(vcfdata)
    nm = ordinalgwas(@formula(y ~ sex), vcfcovfile, nothing; covrowinds=1:190)
    univariate_score_test(vcffile, nm, nsamples, filetype="VCF"; snpinds = [86; 656],rowinds=1:190)
    
    
    
    @time univariate_score_test(vcffile, nm, nsamples, filetype="VCF"; snpinds = [86; 656],rowinds=1:190)
    
    # @profile univariate_score_test(vcffile, nm, nsamples, filetype="VCF"; snpinds = [86; 656],rowinds=1:190)

    # Profile.clear()
    # @profile univariate_score_test(vcffile, nm, nsamples, filetype="VCF"; snpinds = [86; 656], rowinds=1:190)
    # Profile.print(format=:flat)
    # ProfileView.view()

    # Profile.Allocs.clear()
    # Profile.Allocs.@profile sample_rate=0.00005 univariate_score_test(vcffile, nm, nsamples, filetype="VCF"; snpinds = [86; 656], rowinds=1:190)
    # prof = Profile.Allocs.fetch()
    
    
    # PProf.Allocs.pprof(prof; web=true)

    # println("Press Enter to exit after you're done looking at the profile.")
    # readline()

    # open("profile_data.dat", "w") do io
    #     serialize(io, Profile.fetch())
    # end

    # Profile.print()

    scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, end][1:2]
    @test isapprox(scorepvals, [0.00762272, 0.000668338], rtol=1e-3)
    rm("ordinalgwas.null.txt", force=true)
    rm("ordinalgwas.pval.txt", force=true)
end

# data = deserialize("profile_data.dat")
# Profile.clear()
# Profile.merge!(data)
# ProfileView.view()
# rm("profile_data.dat", force=true)


# time for PLINK was 52.269094 seconds (21.08 M allocations: 471.282 GiB, 10.47% gc time, 6.92% compilation time)
# Allocation profiler line by line allocation tracking 
# Link: https://docs.julialang.org/en/v1/manual/profile/
# Figure out which line of code is allocating that much memory 
# Use --track-allocation

# @testset "PLINK score test" begin 
#     nsamples = size(dataset.snparray, 1)
#     nvariants = size(dataset.snparray, 2)
    
#     data = SnpArrays.SnpData(plkfile)
#     nsamples = GeneticVariantBase.n_samples(data)
#     nm = ordinalgwas(@formula(trait ~ sex), covfile, nothing)
#     univariate_score_test(plkfile, nm, nsamples, filetype="PLINK")



#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 4.56531284e-3, 3.10828383e-5, 1.21686724e-5, 8.20686005e-3], rtol=1e-3)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end 

# Finish PLINK before moving on to BGEN

# @testset "BGEN score test" begin
#     b = BGEN.Bgen(bgenfile)
#     nsamples = GeneticVariantBase.n_samples(b)
#     nvariants = GeneticVariantBase.n_variants(b)
#     nm = ordinalgwas(@formula(y ~ sex), bgencovfile, nothing)
#     @time univariate_score_test(bgenfile, nm, nsamples, filetype="BGEN") 
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, end][1:2]
#     @test isapprox(scorepvals, [0.12449778, 0.00055727], rtol=1e-3)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# # PGEN tests 
# p = PGENFiles.Pgen(pgenfile)
# nsamples = GeneticVariantBase.n_samples(p)
# nvariants = GeneticVariantBase.n_variants(p)
# nm = ordinalgwas(@formula(y ~ sex), bgencovfile, nothing)
# univariate_score_test(pgenfile, nm, nsamples, filetype="PGEN")


#number of rows in snpdata 

# vcffile, vcftype, bgenfile, fittednullmodel, nsamples, bedfile, bimfile, bedn)

# univariate_score_test(vcffile, :DS, nm, n_samples, n_variants, :vcf)
# make bgenfile, bedfile, bimfile, vcffile, vcftype optional arguments
# based on the symbol tells you which arguments you should provide 
# require certain arguments 
# add checks for vcffile for example 


#FIX THIS
#bedn argument is redundant with nsamples
# check function signature nsamples nvariants 

# @testset "score test" begin
    # THIS IS PLINK-1
#     @time ordinalgwas(@formula(trait ~ sex), covfile, plkfile, test=:score)
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 4.56531284e-3, 3.10828383e-5, 1.21686724e-5, 8.20686005e-3], rtol=1e-4)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     # VCF
#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, geneticrowinds = 1:190, snpinds = [86; 656], 
#     test = :score, covrowinds = 1:190)
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, end][1:2]
#     @test isapprox(scorepvals, [0.00762272, 0.000668338], rtol=1e-4)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :score)
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, end][1:2]
#     @test isapprox(scorepvals, [0.12449778, 0.00055727], rtol=1e-4)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "LRT test" begin
#     @time ordinalgwas(@formula(trait ~ sex), covfile, plkfile, test=:LRT)
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     lrtpvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(lrtpvals, [1.0, 1.91858366e-3, 1.80505056e-5, 5.87338471e-6, 8.08102258e-3], rtol=1e-4)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     # VCF
#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :GT, snpinds = [86; 656], test = :LRT)
#     lrtpvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(lrtpvals, [0.00955468405473856, 0.0007086063489553798], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         snpinds = [3, 25], test = :LRT)
#         lrtpvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(lrtpvals, [0.000445619, 1.660631e-6], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "snpmodel" begin
#     # dominant model 
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, test=:score, snpmodel=DOMINANT_MODEL)
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 0.14295, 0.000471942, 0.00555348, 0.000652844], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
#     # recessive model 
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, test=:score, snpmodel=RECESSIVE_MODEL)
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 0.00673612, 0.000279908, 4.15322e-5, 0.167642], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "link" begin
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, link=ProbitLink(), pvalfile="opm.pval.txt")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("opm.pval.txt")
#     scorepvals = CSV.read("opm.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 1.00769167e-2, 2.62725649e-5, 1.08974849e-5, 5.10288399e-3], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("opm.pval.txt", force=true)
# end

# @testset "snp mask" begin
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, snpinds=1:5, pvalfile="first5snps.pval.txt")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("first5snps.pval.txt")
#     @test countlines("first5snps.pval.txt") == 6
#     scorepvals = CSV.read("first5snps.pval.txt", DataFrame)[!, :pval]
#     @test isapprox(scorepvals, [1.0, 4.56531284e-3, 3.10828383e-5, 1.21686724e-5, 8.20686005e-3], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("first5snps.pval.txt", force=true)
# end

# @testset "sub samples" begin
#     # only use first 300 samples
#     @time ordinalgwas(@formula(trait ~ sex), covfile, plkfile, test=:score, covrowinds=1:300, geneticrowinds=1:300)
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("ordinalgwas.pval.txt")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 0.00355969, 0.000123604, 5.2213e-6, 0.00758234], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "test formula" begin
#     # score test
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile="GxE.pval.txt", 
#         testformula=@formula(trait ~ snp + snp & sex))
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("GxE.pval.txt")
#     scorepvals = CSV.read("GxE.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.0, 1.74460104e-2, 1.66707324e-4, 4.76376246e-5, 2.91384712e-2], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("GxE.pval.txt", force=true)
#     # LRT, only first 5 SNPs
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile="GxE.pval.txt", 
#         testformula=@formula(trait ~ snp + snp & sex), test=:LRT, snpinds=1:5)
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("GxE.pval.txt")
#     lrtpvals = CSV.read("GxE.pval.txt", DataFrame)[!, :pval]
#     @test isapprox(lrtpvals, [1.0, 7.22410973e-3, 1.01730983e-4, 1.88174211e-5, 2.88295705e-2], rtol=1e-4)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("GxE.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         snpinds = [3, 25], test = :LRT, testformula = @formula(trait ~ snp + snp & sex))
#     lrtpvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(lrtpvals, [0.002084, 8.135205e-6], rtol = 1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "snpset" begin
#     #window
#     #score test
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile = "snpset.pval.txt",
#         snpset=250, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     scorepvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     #@test isapprox(scorepvals, [1.0, 1.74460104e-2, 1.66707324e-4, 4.76376246e-5, 2.91384712e-2], rtol=1e-4)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)
#     #lrt 
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile = "snpset.pval.txt",
#         snpset=25, test=:LRT, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     lrtpvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(lrtpvals, [2.1817554071810948e-13, 0.2865769729670889, 0.32507802233937966,
#     0.3344823237332578, 0.42948375949508427], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     # VCF
#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "snpset.pval.txt",
#     snpset=250, test=:score, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     scorepvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [0.4278366599084349, 
#     0.42781616067453476, 0.4519573757701432, 
#     0.4278763804444088, 0.4345883185481474], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "snpset.pval.txt",
#     snpset=25, test=:LRT, analysistype = "snpset")
#     lrtpvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(lrtpvals, [1.0
#     0.9999996378252629
#     1.0
#     0.9999999999996334
#     0.9999999976994737], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :score, snpset = 8, analysistype = "snpset")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(scorepvals, [0.00767237, 0.5512827], rtol = 1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :LRT, snpset = 8, analysistype = "snpset")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(scorepvals, [0.05257402, 0.5706598], rtol = 1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     #snpset file
#     #score test
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile = "snpset.pval.txt",
#         snpset = snpsetfile, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     scorepvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [1.72134e-5, 0.036925, 0.747855,
#      0.0276508, 0.611958], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)
#     #lrt 
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile = "snpset.pval.txt",
#         snpset = snpsetfile, test = :lrt, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     lrtpvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(lrtpvals, [6.75377e-13, 0.000256566, 0.359382,
#      0.000163268, 0.0867508], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     # VCF
#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "snpset.pval.txt",
#         snpset = vcfsnpsetfile, test = :score, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     scorepvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(scorepvals, [0.06814002639277685, 0.5566664123188036, 
#     0.520381855174413, 0.07557764137466122, 0.5620803022597403], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "snpset.pval.txt",
#         snpset = vcfsnpsetfile, test = :lrt, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     lrtpvals = CSV.read("snpset.pval.txt", DataFrame)[!, :pval][1:5]
#     @test isapprox(lrtpvals, [0.09069975735216675, 0.6465153355309161, 
#     0.6307411986741357, 0.06275888993714969, 0.50252192003468], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :score, snpset = bgensnpsetfile, analysistype = "snpset")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(scorepvals, [0.013317595, 0.454769036], rtol = 1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :lrt, snpset = bgensnpsetfile, analysistype = "snpset")
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, :pval][1:2]
#     @test isapprox(scorepvals, [0.08986309, 0.4688198], rtol = 1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     #specific snp (one snpset)
#     #score test
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile = "snpset.pval.txt",
#         snpset = 50:55, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     scorepvals = open("snpset.pval.txt")
#     scorepval = split(readline(scorepvals))[end]
#     close(scorepvals)
#     @test isapprox(parse(Float64, scorepval), 0.3647126536663949, rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)
#     #lrt 
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, pvalfile = "snpset.pval.txt",
#         snpset = collect(1:15), test=:LRT, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     lrtpvals = open("snpset.pval.txt")
#     lrtpval = split(readline(lrtpvals))[end]
#     close(lrtpvals)
#     @test isapprox(parse(Float64, lrtpval), 7.525696044086955e-15, rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     # VCF
#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "snpset.pval.txt",
#         snpset=85:90, test=:score, analysistype = "snpset")
#     @test isfile("ordinalgwas.null.txt")
#     @test isfile("snpset.pval.txt")
#     scorepvals = open("snpset.pval.txt")
#     scorepval = split(readline(scorepvals))[end]
#     close(scorepvals)
#     @test isapprox(parse(Float64, scorepval), 0.0965927460813927, rtol=1e-2)

#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "snpset.pval.txt",
#         snpset=85:90, test=:lrt, analysistype = "snpset")
#     lrtpvals = open("snpset.pval.txt")
#     lrtpval = split(readline(lrtpvals))[end]
#     close(lrtpvals)
#     @test isapprox(parse(Float64, lrtpval), 0.0732485446883825, rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("snpset.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :score, snpset = [3, 25, 100], analysistype = "snpset")
#     scorepvals = open("ordinalgwas.pval.txt")
#     scorepval = split(readline(scorepvals))[end]
#     close(scorepvals)
#     @test isapprox(parse(Float64, scorepval), 4.422683e-8, rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :LRT, snpset = [3, 25, 100], analysistype = "snpset")
#     scorepvals = open("ordinalgwas.pval.txt")
#     scorepval = split(readline(scorepvals))[end]
#     close(scorepvals)
#     @test isapprox(parse(Float64, scorepval), 2.853246e-8, rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "GxE snp in null" begin
#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, e = :sex, pvalfile = "gxe_snp.pval.txt",
#         snpinds=1:5, test=:score, analysistype = "gxe")
#     @test isfile("gxe_snp.pval.txt")
#     scorepvals = CSV.read("gxe_snp.pval.txt", DataFrame)[!, end][1:5]
#     @test isapprox(scorepvals, [1.0, 0.637742242597749, 0.9667114198051628,
#     0.26352674694121003, 0.7811133315582837], rtol=1e-2)
#     rm("gxe_snp.pval.txt", force=true)

#     ordinalgwas(@formula(trait ~ sex), covfile, plkfile, e = "sex", pvalfile = "gxe_snp.pval.txt",
#         snpinds=1:5, test=:LRT, analysistype = "gxe")
#     @test isfile("gxe_snp.pval.txt")
#     lrtpvals = CSV.read("gxe_snp.pval.txt", DataFrame)[!, end][1:5]
#     @test isapprox(lrtpvals, [1.0, 0.6279730133445315, 0.9671662821946985,
#     0.26693502209463904, 0.7810214899265426], rtol=1e-2)
#     rm("gxe_snp.pval.txt", force=true)

#     # VCF
#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile, e = :sex; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "gxe_snp.pval.txt",
#         snpinds=1:5, test=:score, analysistype = "gxe")
#     scorepvals = CSV.read("gxe_snp.pval.txt", DataFrame)[!, end][1:5]
#     @test isapprox(scorepvals, [0.45861769035708144, 1.0, 0.03804677528312195,
#      0.18254151103030725, 0.34454453512541156], rtol=1e-2)
#     rm("gxe_snp.pval.txt", force=true)

#     ordinalgwas(@formula(y ~ sex), vcfcovfile, vcffile, e = :sex; geneticformat = "VCF", 
#         vcftype = :DS, pvalfile = "gxe_snp.pval.txt",
#         snpinds=1:5, test=:lrt, analysistype = "gxe")
#     @test isfile("gxe_snp.pval.txt")
#     lrtpvals = CSV.read("gxe_snp.pval.txt", DataFrame)[!, end][1:5]
#     @test isapprox(lrtpvals, [0.526667096902957, 1.0, 0.008073040021982156, 
#     0.10590569987122991, 0.3557829099471382], rtol=1e-2)
#     rm("gxe_snp.pval.txt", force=true)

#     # BGEN
#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :score, snpinds = 1:5, analysistype = "gxe", e = :sex)
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, end][1:5]
#     @test isapprox(scorepvals, [0.415677
#         0.92019145
#         0.8975205
#         0.4947529
#         0.4947529], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)

#     ordinalgwas(@formula(y ~ sex), bgencovfile, bgenfile; geneticformat = "BGEN",  
#         test = :lrt, snpinds = 1:5, analysistype = "gxe", e = :sex)
#     scorepvals = CSV.read("ordinalgwas.pval.txt", DataFrame)[!, end][1:5]
#     @test isapprox(scorepvals, [0.419214
#         0.9207400
#         0.8981011
#         0.4947914
#         0.4947914], rtol=1e-2)
#     rm("ordinalgwas.null.txt", force=true)
#     rm("ordinalgwas.pval.txt", force=true)
# end

# @testset "split, gz" begin
#     # split hapmap3 by chromosome
#     SnpArrays.split_plink(plkfile, :chromosome; prefix = datadir * "/hapmap3.chr.")
#     # compress to gz
#     for chr in 1:23
#         plinkfile = plkfile * ".chr." * string(chr)
#         SnpArrays.compress_plink(plinkfile)
#         @test isfile(plinkfile * ".bed.gz")
#         @test isfile(plinkfile * ".fam.gz")
#         @test isfile(plinkfile * ".bim.gz")
#     end
#     # fit null model
#     @time nm = ordinalgwas(@formula(trait ~ sex), covfile, nothing)
#     @test isfile("ordinalgwas.null.txt")
#     # gwas by chromosome, refit null model each time, use uncompressed Plink set
#     @time for chr in 1:23
#         plinkfile = plkfile * ".chr." * string(chr)
#         pvalfile = plkfile * ".chr." * string(chr) * ".pval.txt"
#         ordinalgwas(@formula(trait ~ sex), covfile, plinkfile, pvalfile = pvalfile)
#         @test isfile(pvalfile)
#         if chr == 1
#             pvals_chr1 = CSV.read(pvalfile, DataFrame)[!, end][1:5]
#             @test isapprox(pvals_chr1, [1.0, 4.56531284e-3, 3.10828383e-5, 1.21686724e-5, 8.20686005e-3], rtol=1e-2)    
#         end
#         rm(plinkfile * ".pval.txt", force=true)
#     end
#     # gwas by chromosome, use fitted null model each time, use uncompressed Plink set
#     @time for chr in 1:23
#         plinkfile = plkfile * ".chr." * string(chr)
#         pvalfile = plkfile * ".chr." * string(chr) * ".pval.txt"
#         ordinalgwas(nm, plinkfile, pvalfile = pvalfile)
#         @test isfile(pvalfile)
#         if chr == 1
#             pvals_chr1 = CSV.read(pvalfile, DataFrame)[!, end][1:5]
#             @test isapprox(pvals_chr1, [1.0, 4.56531284e-3, 3.10828383e-5, 1.21686724e-5, 8.20686005e-3], rtol=1e-2)    
#         end
#         rm(pvalfile, force=true)
#     end
#     # gwas by chromosome, use fitted null model each time, use compressed bed and bim files
#     @time for chr in 1:23
#         bedfile = plkfile * ".chr." * string(chr) * ".bed.gz"
#         bimfile = plkfile * ".chr." * string(chr) * ".bim.gz"
#         pvalfile = plkfile * ".chr." * string(chr) * ".pval.txt"
#         ordinalgwas(nm, bedfile, bimfile, 324; pvalfile = pvalfile)
#         @test isfile(pvalfile)
#         if chr == 1
#             pvals_chr1 = CSV.read(pvalfile, DataFrame)[!, end][1:5]
#             @test isapprox(pvals_chr1, [1.0, 4.56531284e-3, 3.10828383e-5, 1.21686724e-5, 8.20686005e-3], rtol=1e-2)    
#         end
#         rm(pvalfile, force=true)
#     end
#     # clean up
#     # delete result files
#     isfile("ordinalgwas.null.txt") && rm("ordinalgwas.null.txt")
#     for chr in 1:26
#         plinkfile = plkfile * ".chr." * string(chr)
#         # delete uncompressed chromosome Plink files
#         rm(plinkfile * ".bed", force=true)
#         rm(plinkfile * ".fam", force=true)
#         rm(plinkfile * ".bim", force=true)
#         # delete compressed chromosome Plink files
#         rm(plinkfile * ".bed.gz", force=true)
#         rm(plinkfile * ".fam.gz", force=true)
#         rm(plinkfile * ".bim.gz", force=true)
#         # delete pval files
#         rm(plinkfile * ".pval.txt", force=true)
#     end
# end
