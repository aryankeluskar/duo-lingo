import Foundation

extension Word {
  static let linearAlgebra: [Word] = [
    Word(
      deck: .linearAlgebra,
      term: "eigenvector",
      note: "eigenvalues",
      meaning: "A nonzero v that A only stretches:  Av = λv",
      example: "Eigenvalues solve  det(A − λI) = 0",
      exampleTranslation: "Eigenvectors are the directions a transformation doesn't turn."
    ),
    Word(
      deck: .linearAlgebra,
      term: "determinant",
      note: "matrices",
      meaning: "The factor by which A scales signed area or volume",
      example: "det [a b; c d] = ad − bc",
      exampleTranslation: "det A = 0 means A flattens space, so it has no inverse."
    ),
    Word(
      deck: .linearAlgebra,
      term: "rank–nullity theorem",
      note: "vector spaces",
      meaning: "rank A + nullity A = the number of columns of A",
      example: "A 3 × 5 matrix of rank 3 has a 2-dimensional null space.",
      exampleTranslation: "Each input dimension is either kept (rank) or crushed to zero (nullity)."
    ),
    Word(
      deck: .linearAlgebra,
      term: "invertible matrix theorem",
      note: "matrices",
      meaning: "Square A is invertible ⇔ det A ≠ 0 ⇔ Ax = 0 only for x = 0",
      example: "⇔ full rank ⇔ independent columns ⇔ 0 is not an eigenvalue",
      exampleTranslation: "Dozens of conditions, one idea: A loses no information."
    ),
    Word(
      deck: .linearAlgebra,
      term: "linear independence",
      note: "vector spaces",
      meaning: "No vector in the set is a combination of the others",
      example: "c₁v₁ + ⋯ + cₙvₙ = 0  only when every cᵢ = 0",
      exampleTranslation: "Each independent vector adds a genuinely new direction."
    ),
    Word(
      deck: .linearAlgebra,
      term: "orthogonal matrix",
      note: "inner products",
      meaning: "A square Q with QᵀQ = I, so Q⁻¹ = Qᵀ",
      example: "Rotation:  [cos θ  −sin θ;  sin θ  cos θ]",
      exampleTranslation: "It preserves lengths and angles: a rigid motion."
    ),
    Word(
      deck: .linearAlgebra,
      term: "Gram–Schmidt",
      note: "orthogonalization",
      meaning: "Turns independent vectors into an orthonormal basis",
      example: "u₂ = v₂ − (v₂ · e₁) e₁,   then  e₂ = u₂ / ‖u₂‖",
      exampleTranslation: "It's the algorithm behind the QR factorization."
    ),
    Word(
      deck: .linearAlgebra,
      term: "diagonalization",
      note: "eigenvalues",
      meaning: "A = PDP⁻¹: eigenvectors in P, eigenvalues in D",
      example: "Aᵏ = PDᵏP⁻¹",
      exampleTranslation: "Possible exactly when A has n independent eigenvectors."
    ),
    Word(
      deck: .linearAlgebra,
      term: "spectral theorem",
      note: "symmetric matrices",
      meaning: "Every real symmetric matrix is orthogonally diagonalizable",
      example: "A = QΛQᵀ,   Λ real and diagonal,  Q orthogonal",
      exampleTranslation: "It's why PCA can rotate data onto uncorrelated axes."
    ),
    Word(
      deck: .linearAlgebra,
      term: "least squares",
      note: "projections",
      meaning: "The x̂ that minimizes ‖Ax − b‖ solves the normal equations",
      example: "AᵀA x̂ = Aᵀb",
      exampleTranslation: "Fitting a line to data is projecting b onto the column space of A."
    ),
    Word(
      deck: .linearAlgebra,
      term: "trace",
      note: "matrices",
      meaning: "The sum of the diagonal entries, and of the eigenvalues",
      example: "tr A = Σ λᵢ,     det A = Π λᵢ",
      exampleTranslation: "Two numbers you can read off a matrix that pin down its eigenvalues' sum and product."
    ),
    Word(
      deck: .linearAlgebra,
      term: "singular value decomposition",
      note: "factorizations",
      meaning: "Every matrix factors as A = UΣVᵀ",
      example: "σ₁ ≥ σ₂ ≥ ⋯ ≥ 0 are the singular values",
      exampleTranslation: "Keeping the largest σᵢ gives the best low-rank approximation (Eckart–Young)."
    ),
  ]
}
