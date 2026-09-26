import Foundation

extension Word {
  static let chemistry: [Word] = [
    Word(
      deck: .chemistry,
      term: "Henderson–Hasselbalch",
      note: "acid–base",
      meaning: "The pH of a buffer from its pKₐ and base-to-acid ratio",
      example: "pH = pKₐ + log([A⁻] / [HA])",
      exampleTranslation: "When [A⁻] = [HA], pH = pKₐ, where the buffer resists change best."
    ),
    Word(
      deck: .chemistry,
      term: "Gibbs free energy",
      note: "thermodynamics",
      meaning: "ΔG < 0 means spontaneous at constant T and P",
      example: "ΔG = ΔH − TΔS,    ΔG° = −RT ln K",
      exampleTranslation: "Enthalpy and entropy trade off; temperature decides which one wins."
    ),
    Word(
      deck: .chemistry,
      term: "Le Chatelier's principle",
      note: "equilibrium",
      meaning: "A disturbed equilibrium shifts to oppose the change",
      example: "N₂ + 3H₂ ⇌ 2NH₃: raising the pressure favors ammonia.",
      exampleTranslation: "Four moles of gas become two, so squeezing the system pushes it right."
    ),
    Word(
      deck: .chemistry,
      term: "SN2",
      note: "organic mechanisms",
      meaning: "One-step substitution by backside attack, with inversion",
      example: "rate = k[R–X][Nu⁻];   methyl > 1° > 2°,  3° doesn't react",
      exampleTranslation: "Crowding around the carbon blocks the incoming nucleophile."
    ),
    Word(
      deck: .chemistry,
      term: "SN1",
      note: "organic mechanisms",
      meaning: "Two-step substitution through a carbocation intermediate",
      example: "rate = k[R–X];   3° > 2°,  favored by polar protic solvents",
      exampleTranslation: "The flat carbocation is attacked from either face, so a stereocenter racemizes."
    ),
    Word(
      deck: .chemistry,
      term: "Arrhenius equation",
      note: "kinetics",
      meaning: "How a rate constant grows with temperature",
      example: "k = A·e^(−Eₐ / RT)",
      exampleTranslation: "The higher the activation energy, the more a reaction speeds up with heat."
    ),
    Word(
      deck: .chemistry,
      term: "Nernst equation",
      note: "electrochemistry",
      meaning: "A cell's potential away from standard conditions",
      example: "E = E° − (RT / nF) ln Q",
      exampleTranslation: "At equilibrium Q = K and E = 0: the battery is dead."
    ),
    Word(
      deck: .chemistry,
      term: "Hess's law",
      note: "thermochemistry",
      meaning: "A reaction's ΔH is the same whatever path it takes",
      example: "ΔH°rxn = ΣΔHf°(products) − ΣΔHf°(reactants)",
      exampleTranslation: "Enthalpy is a state function, so reactions add like equations."
    ),
    Word(
      deck: .chemistry,
      term: "hybridization",
      note: "bonding",
      meaning: "Mixing atomic orbitals to account for molecular shape",
      example: "sp³ 109.5° (CH₄)  ·  sp² 120° (C₂H₄)  ·  sp 180° (C₂H₂)",
      exampleTranslation: "Count the electron domains around an atom to find its hybridization."
    ),
    Word(
      deck: .chemistry,
      term: "aromaticity",
      note: "organic structure",
      meaning: "A cyclic, planar, fully conjugated ring with 4n + 2 π electrons",
      example: "Benzene: 6 π electrons (n = 1).  Cyclobutadiene: 4, antiaromatic.",
      exampleTranslation: "Hückel's rule explains why aromatic rings substitute instead of adding."
    ),
    Word(
      deck: .chemistry,
      term: "ideal gas law",
      note: "gases",
      meaning: "Relates a gas's pressure, volume, amount and temperature",
      example: "PV = nRT,    R = 8.314 J/(mol·K)",
      exampleTranslation: "Real gases stray from it at high pressure and low temperature."
    ),
    Word(
      deck: .chemistry,
      term: "Pauli exclusion principle",
      note: "quantum chemistry",
      meaning: "No two electrons in an atom share all four quantum numbers",
      example: "Each orbital holds at most two electrons, with opposite spins.",
      exampleTranslation: "It's why electrons fill shells, and why the periodic table has its shape."
    ),
  ]
}
