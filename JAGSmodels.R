# Models
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# META ANALYSIS----------------------------------------------------------------
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# normally distributed data, grand mean
ma.normal.file <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisNormal.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisNormal.jags")
cat("
    model {
    for (i in 1:num.observations) {
    observed.y[i] ~ dnorm(estimated.y[i], observed.prec[i])
    observed.prec[i] <- 1 / observed.var[i]
    estimated.y[i] ~ dnorm(overall.mean, overall.precision)
    }
    overall.precision ~ dgamma(0.001, 0.001)
    overall.sd <- sqrt(1 / overall.precision)
    overall.mean ~ dnorm(0, 1E-3)
    }", fill = TRUE)
sink()

# normally distributed data, groupwise means
ma.normal.group.file <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisNormalGroup.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisNormalGroup.jags")
cat("
    model {
    for (i in 1:num.observations) {
    observed.y[i] ~ dnorm(estimated.y[i], observed.prec[i])
    observed.prec[i] <- 1 / observed.var[i]
    estimated.y[i] ~ dnorm(groupwise.mean[i], overall.precision)
    groupwise.mean[i] <- beta[group[i]]
    }
    overall.precision ~ dgamma(0.001, 0.001)
    overall.sd <- sqrt(1 / overall.precision)
    
    for (j in 1:num.group) {
    beta[j] ~ dnorm(0, 1E-3)
    }
    }", fill = TRUE)
sink()

# binomially distributed data, grand mean
ma.binom.file <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisBinom.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisBinom.jags")
cat("model
    {
    for (i in 1:num.observations) {
    observed.counts[i] ~ dbin(observed.prob[i], sample.size[i])
    logit(observed.prob[i]) <- estimated.prob[i]
    estimated.prob[i] ~ dnorm(overall.mean, overall.precision)
    }
    overall.mean ~ dnorm(0, 1E-6)
    overall.sd ~ dunif(0, 100)
    overall.precision <- pow(overall.sd, -2)
    }
    ")
sink()

# binomially distributed data, groupwise means
ma.binom.group.file <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisBinomGroup.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisBinomGroup.jags")
cat("model
    {
    for (i in 1:num.observations) {
    observed.counts[i] ~ dbin(observed.prob[i], sample.size[i])
    logit(observed.prob[i]) <- estimated.prob[i]
    estimated.prob[i] ~ dnorm(groupwise.mean[i], overall.precision)
    groupwise.mean[i] <- beta[group[i]]
    }
    overall.sd ~ dunif(0, 100)
    overall.precision <- pow(overall.sd, -2)
    
    for (j in 1:num.group) {
    beta[j] ~ dnorm(0, 1E-3)
    }
    }
    ")
sink()

# truncated normal distributed data, grand mean
ma.tnormal.file <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisTNorm.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisTNorm.jags")
cat("
    # truncation not equal to zero or one because of numerical issues
    model {
    for (i in 1:num.observations) {
    observed.y[i] ~ dnorm(estimated.y[i], observed.prec[i]) T(0.000001,0.999999)
    observed.prec[i] <- 1 / observed.var[i]
    estimated.y[i] ~ dnorm(overall.mean, overall.precision) T(0.000001,0.999999)
    }
    overall.precision ~ dgamma(0.001, 0.001) T(0.000001,)
    overall.sd <- sqrt(1 / overall.precision)
    overall.mean ~ dnorm(0, 1E-3) T(0,1)
    }",fill = TRUE)
sink()

# truncated normal distributed data, groupwise means
ma.tnormal.group.file <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisTNormalGroup.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/MetaAnalysisTNormalGroup.jags")
cat("
    model {
    for (i in 1:num.observations) {
    observed.y[i] ~ dnorm(estimated.y[i], observed.prec[i]) T(0.000001,0.999999)
    observed.prec[i] <- 1 / observed.var[i]
    estimated.y[i] ~ dnorm(groupwise.mean[i], overall.precision) T(0.000001,0.999999)
    groupwise.mean[i] <- beta[group[i]]
    }
    overall.precision ~ dgamma(0.001, 0.001) T(0.000001,)
    overall.sd <- sqrt(1 / overall.precision)
    
    for (j in 1:num.group) {
    beta[j] ~ dnorm(0, 1E-3)  T(0,1)
    }
    }", fill = TRUE)
sink()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MODEL SELECTION----------------------------------------------------------
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#
# fit data to a given distribution using the log-likelihood
#
# normal distribution
# data ~ N(mu, sigma)
normal <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/normal.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/normal.jags")
cat("
    model {
    for (i in 1:num.observations) {
    y[i] ~ dnorm(param1, tau.param2)
    loglik[i] <- logdensity.norm(y[i], param1, tau.param2)
    }
    param1 ~ dnorm(0, 1E-6)
    param2 ~ dunif(0, 1E6)
    tau.param2 <- pow(param2, -2)
    }", fill = TRUE)
sink()

# lognormal distribution
# data ~ LN(mu, sigma)
lognormal <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/lognormal.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/lognormal.jags")
cat("
    model {
    for (i in 1:num.observations) {
    y[i] ~ dlnorm(param1, tau.param2)
    loglik[i] <- logdensity.lnorm(y[i], param1, tau.param2)
    }
    param1 ~ dnorm(0, 1E-6)
    param2 ~ dunif(0, 1E6)
    tau.param2 <- pow(param2, -2)
    }", fill = TRUE)
sink()

# exponential distribution
# data ~ Exponential(lambda)
exponential <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/exponential.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/exponential.jags")
cat("
    model {
    for (i in 1:num.observations) {
    y[i] ~ dexp(param1)
    loglik[i] <- logdensity.exp(y[i], param1)
    }
    param1 ~ dunif(0, 1E6)
    }", fill = TRUE)
sink()

# power law function = Pareto distribution
# data ~ Pareto(a, c)
pareto <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/pareto.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/pareto.jags")
cat("
    model {
    for (i in 1:num.observations) {
    y[i] ~ dpar(param1, param2)
    loglik[i] <- logdensity.par(y[i], param1, param2)
    }
    param1 ~ dunif(0, 1E6)
    param2 ~ dunif(0, 1E6)
    }", fill = TRUE)
sink()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# SPECIES CHARACTERISTICS------------------------------------------------------
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# hierarchical Bayesian t-test
mean.difference.model <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/EstimateMeanDifferences.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/EstimateMeanDifferences.jags")
cat("
    model {
    # out- and in-strengths for each species grouped by invasive status
    # are the means different? (t-test)
    #
    # likelihood
    #
    # out-strength
    for (i in 1:length(s.out.obs)) {
    s.out.obs[i] ~ dnorm(s.out[i], tau.out.obs[i])
    tau.out.obs[i] <- pow(sigma.out.obs[i], -2)
    }
    for (i in 1:length(s.out.obs)) {
    s.out[i] ~ dnorm(mu.out[i], tau.out)
    mu.out[i] <- beta0.out + beta1.out * groupID.out[i]
    }

    # in-strength
    for (i in 1:length(s.in.obs)) {
    s.in.obs[i] ~ dnorm(s.in[i], tau.in.obs[i])
    tau.in.obs[i] <- pow(sigma.in.obs[i], -2)
    }
    for (i in 1:length(s.in.obs)) {
    s.in[i] ~ dnorm(mu.in[i], tau.in)
    mu.in[i] <- beta0.in + beta1.in * groupID.in[i]
    }

    #
    # priors
    #
    beta0.out ~ dnorm(0, 1.0E-6)
    beta1.out ~ dnorm(0, 1.0E-6)
    beta0.in ~ dnorm(0, 1.0E-6)
    beta1.in ~ dnorm(0, 1.0E-6)
    # half-cauchy priors for sigma
    tau.out <- pow(sigma.out, -2)
    sigma.out ~ dt(0, pow(3, -2), 1) T(0,)
    tau.in <- pow(sigma.in, -2)
    sigma.in ~ dt(0, pow(3, -2), 1) T(0,)
    }", fill = TRUE)
sink()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ADDITIVITY-------------------------------------------------------------------
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# BAYESIAN HIERARCHICAL MODEL OF DIFFERENCE IN RII
# dependent variable is standardized difference in RII, goes as a Normal distribution
# parameter mu is fit separately to each network (5 total)
# the mu's are themselves normally distributed
# mu from this hierarchical level is the parameter of interest (mean difference in RII accounting for the intra-network structure)
# sigma is the sd among groups and sigma.g is the sd within groups
additive.model <- "/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/AdditiveModel.jags"
sink("/Users/nicolekinlock/Documents/NetworkMetaAnalysis/Input/JAGSModels/AdditiveModel.jags")
cat("
    model {
    for (i in 1:length(y)) {
    y[i] ~ dnorm(mu[i], tau)
    mu[i] <- beta[group[i]]
    }
    tau ~ dgamma(0.001, 0.001)
    sigma <- sqrt(1 / tau)
    for (j in 1:g) {
    beta[j] ~ dnorm(mu.g, tau.g)
    }
    mu.g ~ dnorm(0, 1E-3)
    tau.g ~ dgamma(0.001, 0.001)
    sigma.g <- sqrt(1 / tau.g)
    }", fill = TRUE)
sink()
