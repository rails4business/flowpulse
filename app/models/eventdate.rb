class Eventdate < ApplicationRecord
  # taxbranch si riferisce all'esercizio che è stato completato
  belongs_to :taxbranch
  # lead è l'utente che ha completato l'esercizio (se usi Devise, questo sarà User)
  belongs_to :lead

  # Aggiungi le validazioni
  validates :cycle, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :taxbranch, presence: true
  validates :lead, presence: true
  validates :status, presence: true

  # Definisci gli stati (esempio comune: 1=Completato, 2=In corso)
  enum :status, { pending: 0, completed: 1, skipped: 2 }
end
