(TeX-add-style-hook "StrasheelaMotivation"
 (lambda ()
    (LaTeX-add-bibliographies
     "/home/t/texte/PhD/bibtex/PhD/music-theorie"
     "/home/t/texte/PhD/bibtex/PhD/music-CP"
     "/home/t/texte/PhD/bibtex/PhD/algo-comp"
     "/home/t/texte/PhD/bibtex/PhD/computer-music"
     "/home/t/texte/PhD/bibtex/PhD/computer-science"
     "/home/t/texte/PhD/bibtex/PhD/Oz"
     "/home/t/texte/PhD/bibtex/PhD/AI"
     "/home/t/texte/PhD/bibtex/PhD/CP"
     "/home/t/texte/PhD/bibtex/PhD/score-representation"
     "/home/t/texte/PhD/bibtex/PhD/music-AI"
     "/home/t/texte/PhD/bibtex/PhD/further")
    (LaTeX-add-labels
     "sec:intro:approach-taken")
    (TeX-run-style-hooks
     "latex2e"
     "scrartcl10"
     "scrartcl"
     "TorstenAnders-PhDThesis-header")))

