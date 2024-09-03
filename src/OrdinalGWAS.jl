__precompile__()

module OrdinalGWAS

using LinearAlgebra
using CSV, DataFrames, Distributions, Reexport
using SnpArrays, VCFTools, VariantCallFormat, BGEN
using MathOptInterface
const MOI = MathOptInterface
@reexport using OrdinalMultinomialModels
using GeneticVariantBase

export ordinalgwas, univariate_score_test
# export VCFTools.GeneticVariantBase

include("gwas.jl")

end
