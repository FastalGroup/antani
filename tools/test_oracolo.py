"""L'oracolo deve riprodurre codici fiscali pubblicati."""
import unittest

from oracolo import codice_fiscale


class TestOracolo(unittest.TestCase):
    def test_esempi_pubblicati(self):
        self.assertEqual(codice_fiscale("Rossi", "Mario", "M", 1, 1, 1980, "H501"), "RSSMRA80A01H501U")
        self.assertEqual(codice_fiscale("Moretti", "Matteo", "M", 9, 4, 1925, "F205"), "MRTMTT25D09F205Z")

    def test_calcolo_a_mano(self):
        self.assertEqual(codice_fiscale("Rossi", "Mario", "M", 15, 3, 1985, "H501"), "RSSMRA85C15H501R")

    def test_regole_di_cognome_e_nome(self):
        self.assertEqual(codice_fiscale("Fo", "Ai", "F", 1, 1, 2000, "H501")[:6], "FOXAIX")
        self.assertEqual(codice_fiscale("Rossi", "Gianfranco", "M", 1, 1, 2000, "H501")[3:6], "GFR")
        self.assertEqual(codice_fiscale("Bianchi", "Laura", "F", 7, 7, 1970, "L219")[9:11], "47")


if __name__ == "__main__":
    unittest.main()
