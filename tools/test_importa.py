"""Test dello script di import (python3 -m unittest discover -s tools)."""
import importlib.util
import unittest
from pathlib import Path

_spec = importlib.util.spec_from_file_location("importa", Path(__file__).with_name("importa-luoghi.py"))
imp = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(imp)


class TestNormalizzazione(unittest.TestCase):
    def test_accenti_e_punteggiatura(self):
        self.assertEqual(imp.normalizza("Sant'Angelo d'Alife"), "SANTANGELODALIFE")
        self.assertEqual(imp.normalizza("Forlì"), "FORLI")
        self.assertEqual(imp.normalizza("Aglié"), "AGLIE")
        self.assertEqual(imp.normalizza("S. Maria Capua-Vetere"), "SMARIACAPUAVETERE")

    def test_sharp_s_e_latino_esteso(self):
        self.assertEqual(imp.normalizza("Eppan an der Weinstraße"), "EPPANANDERWEINSTRASSE")
        self.assertEqual(imp.normalizza("ČEPOVAN"), "CEPOVAN")
        self.assertEqual(imp.normalizza("Šmarje"), "SMARJE")


class TestCodifiche(unittest.TestCase):
    def test_hash_i32(self):
        self.assertEqual(imp.hash32("A"), 1)
        self.assertEqual(imp.hash32("AB"), 1 * 31 + 2)
        self.assertEqual(imp.hash32("ROMA"), ((18 * 31 + 15) * 31 + 13) * 31 + 1)
        lungo = imp.hash32("APPIANOSULLASTRADADELVINO")
        self.assertTrue(-(1 << 31) <= lungo < (1 << 31))

    def test_provincia(self):
        self.assertEqual(imp.provincia("AA"), 27)
        self.assertEqual(imp.provincia("EE"), 135)
        self.assertEqual(imp.provincia("TN"), 20 * 26 + 14)

    def test_impacchetta(self):
        self.assertEqual(imp.impacchetta("H501"), 8501)
        self.assertEqual(imp.impacchetta("Z404"), 26404)
        self.assertEqual(imp.impacchetta("A001"), 1001)
        with self.assertRaises(ValueError):
            imp.impacchetta("ND")


class TestGenerazione(unittest.TestCase):
    def luoghi(self, voci):
        luoghi = {}
        for nome, codice, periodo, province in voci:
            voce = luoghi.setdefault(nome, {}).setdefault(codice, {"periodi": set(), "province": set()})
            voce["periodi"].add(periodo)
            voce["province"].update(province)
        return luoghi

    def test_codice_unico_su_una_riga(self):
        testo = imp.genera(self.luoghi([("ROMA", "H501", (18840911, 99991231), {imp.provincia("RM")})]))
        self.assertIn(f"    {imp.hash32('ROMA')}: r come se fosse 8501\n", testo)
        self.assertTrue(testo.rstrip().endswith("vaffanzum r!"))

    def test_codici_multipli_con_date_e_province(self):
        testo = imp.genera(self.luoghi([
            ("LIVO", "E623", (18610317, 19280522), {imp.provincia("CO")}),
            ("LIVO", "E624", (19201016, 99991231), {imp.provincia("TN")}),
            ("ROMA", "H501", (18840911, 99991231), {imp.provincia("RM")}),
        ]))
        self.assertIn("bituma LIVO", testo)
        self.assertIn("che cos'è data? maggiore uguale a 18610317: che cos'è data? minore uguale a 19280522:", testo)
        self.assertIn(f"che cos'è prov? 0: o magari {imp.provincia('TN')}: o tarapia tapioco: ok come se fosse 0", testo)
        self.assertIn("r come se fosse 5624", testo)
        self.assertIn("o magari maggiore di 1: r come se fosse -2", testo)

    def test_collisione(self):
        imp.controlla_collisioni({"AB": {}, "BA": {}})
        originale = imp.MOLTIPLICATORE
        imp.MOLTIPLICATORE = 1
        try:
            with self.assertRaises(SystemExit):
                imp.controlla_collisioni({"AB": {}, "BA": {}})
        finally:
            imp.MOLTIPLICATORE = originale


if __name__ == "__main__":
    unittest.main()
