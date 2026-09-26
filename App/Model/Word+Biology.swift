import Foundation

extension Word {
  static let biology: [Word] = [
    Word(
      deck: .biology,
      term: "central dogma",
      note: "molecular biology",
      meaning: "DNA → RNA → protein",
      example: "Transcription copies DNA into mRNA; ribosomes translate mRNA into protein.",
      exampleTranslation: "Sequence information flows from nucleic acid to protein, never back out of protein."
    ),
    Word(
      deck: .biology,
      term: "Krebs cycle",
      note: "cellular respiration",
      meaning: "Oxidizes acetyl-CoA to CO₂ in the mitochondrial matrix",
      example: "Per acetyl-CoA: 3 NADH, 1 FADH₂, 1 GTP (or ATP), 2 CO₂",
      exampleTranslation: "It loads the electron carriers that power oxidative phosphorylation."
    ),
    Word(
      deck: .biology,
      term: "chemiosmosis",
      note: "bioenergetics",
      meaning: "ATP made by protons flowing down a membrane gradient",
      example: "H⁺ returns through ATP synthase:  ADP + Pᵢ → ATP",
      exampleTranslation: "The electron transport chain pumps protons out; ATP synthase spends the gradient."
    ),
    Word(
      deck: .biology,
      term: "Michaelis constant",
      note: "enzyme kinetics",
      meaning: "The substrate concentration at which v = ½ Vₘₐₓ",
      example: "v = Vₘₐₓ[S] / (Kₘ + [S])",
      exampleTranslation: "A low Kₘ means the enzyme is already half-saturated at low substrate."
    ),
    Word(
      deck: .biology,
      term: "Hardy–Weinberg",
      note: "population genetics",
      meaning: "Allele frequencies stay constant when no evolutionary force acts",
      example: "p² + 2pq + q² = 1,   p + q = 1",
      exampleTranslation: "Departures flag selection, drift, gene flow, mutation or non-random mating."
    ),
    Word(
      deck: .biology,
      term: "operon",
      note: "gene regulation",
      meaning: "A cluster of genes transcribed together from one promoter",
      example: "lac operon: allolactose releases the repressor, so lacZYA is transcribed.",
      exampleTranslation: "Bacteria switch a whole pathway on or off in one move."
    ),
    Word(
      deck: .biology,
      term: "meiosis",
      note: "cell division",
      meaning: "Two divisions that halve the chromosome number, 2n → n",
      example: "Crossing over in prophase I; homologs separate in anaphase I.",
      exampleTranslation: "It makes gametes and shuffles alleles into new combinations."
    ),
    Word(
      deck: .biology,
      term: "action potential",
      note: "neurobiology",
      meaning: "An all-or-none reversal of a neuron's membrane potential",
      example: "Na⁺ rushes in (−70 → +30 mV), then K⁺ flows out to repolarize.",
      exampleTranslation: "Voltage-gated channels open in sequence, so the signal travels without fading."
    ),
    Word(
      deck: .biology,
      term: "Calvin cycle",
      note: "photosynthesis",
      meaning: "Fixes CO₂ into sugar in the stroma, using ATP and NADPH",
      example: "RuBisCO:  CO₂ + RuBP → 2 × 3-phosphoglycerate",
      exampleTranslation: "The light reactions supply the energy; this cycle builds the carbohydrate."
    ),
    Word(
      deck: .biology,
      term: "codon",
      note: "translation",
      meaning: "Three mRNA bases that specify one amino acid, or stop",
      example: "AUG = methionine (start);  UAA, UAG, UGA = stop",
      exampleTranslation: "64 codons for 20 amino acids, so the genetic code is redundant."
    ),
    Word(
      deck: .biology,
      term: "Okazaki fragments",
      note: "DNA replication",
      meaning: "Short DNA pieces synthesized on the lagging strand",
      example: "Polymerase only builds 5′ → 3′; DNA ligase seals the fragments together.",
      exampleTranslation: "The strands are antiparallel, so one must be copied backward, in pieces."
    ),
    Word(
      deck: .biology,
      term: "PCR",
      note: "biotechnology",
      meaning: "Amplifies a DNA segment exponentially by thermal cycling",
      example: "Denature 95 °C → anneal ≈ 55 °C → extend 72 °C",
      exampleTranslation: "Each cycle roughly doubles the target: 30 cycles ≈ 10⁹ copies."
    ),
  ]
}
