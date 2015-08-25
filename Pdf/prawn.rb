require 'prawn'
require 'prawn-table'

def header
  cells = [{content: "Aides et subventions", colspan: 3},	{content: "Avantages fiscaux", colspan: 2}, {content: "Crédits dédiés"}]
  cells.map {|cell| cell.merge({align: :center, size: 8})}
end

def row1
  texts = ["Certificats d’Economie d’Energie", "Aides de l’ANAH", "Aides locales", "Crédit d’impôt transition énergétique", "Exonération partielle de taxe foncière", "Montant de l’Eco-prêt à taux zéro"]
  texts.map {|text| {content: text, font_style: :bold, align: :center, size: 10}}
end

def row2
  cells = [{content: "0 €", text_color: "9F0004"}, {content: "3250 €", text_color: "0B5AB2"}, {content: ""}, {content: "600 €", text_color: "0B5AB2"}, {content: ""}, {content: "7000 €", text_color: "0B5AB2"}]
  cells.map {|cell| cell.merge({font_style: :bold, align: :center, size: 9}) }
end

def row3
  [{content: "DETAIL", font_style: :bold, size: 9}]*6
end

def row4
  [{content: "", colspan: 6, height: 20}]
end

def row5
  [{content: "Lors de la réalisation de travaux à portée énergétique, il est possible d’émettre des certificats d’économie d’énergie. <br><br> Les Certificats d’économie d’énergie sont vendus aux grands fournisseurs d’énergie, qui ont l’obligation d’acheter un certain quota de certificats d’économie d’énergie pour remplir leur obligation fixée par le « … ». <br><br> <b>A savoir</b> : Les Certificats d’Economie d’Energie et ne sont pas cumulables avec les aides de l’ANAH. <br><br> <u>Vos travaux éligibles aux CEE sont :</u>", inline_format: true, size: 6}]*6
end

Prawn::Font::AFM.hide_m17n_warning = true
pdf_file = Tempfile.new(['plan_financement', '.pdf'])
Prawn::Document.generate(pdf_file) do |pdf|
  pdf.text "Addresse"
  pdf.move_down 20

  table_data = [header, row1, row2, row3, row4, row5]
  pdf.table(table_data, cell_style: {font: "Helvetica"})
end
