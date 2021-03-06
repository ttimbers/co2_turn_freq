all: results/final_ha_plot.pdf results/final_length_plot.pdf

data/all_reverals.rev data/all_good_numbers.dat data/all_body_size.dat: src/run_chore.sh
	bash src/run_chore.sh data

data/all_reverals_parsed.rev: src/parse_column.R data/all_reverals.rev
	Rscript src/parse_column.R data/all_reverals.rev data/all_reverals_parsed.rev object_id t_reversal reversal_distance reversal_duration

data/all_good_numbers_parsed.dat: src/parse_column.R data/all_good_numbers.dat
	Rscript src/parse_column.R data/all_good_numbers.dat data/all_good_numbers_parsed.dat time good_number

data/all_body_size_parsed.dat: src/parse_column.R data/all_body_size.dat
	Rscript src/parse_column.R data/all_body_size.dat data/all_body_size_parsed.dat time id area midline morphwidth

results/final_ha_plot.pdf: src/analyze_turns.R data/all_body_size_parsed.dat data/all_good_numbers_parsed.dat
	if [ ! -d "results/" ]; then mkdir results; fi;
	Rscript src/analyze_turns.R data/all_body_size_parsed.dat data/all_good_numbers_parsed.dat results/final

results/final_length_plot.pdf: src/quick_body_size.R data/all_body_size_parsed.dat
		if [ ! -d "results/" ]; then mkdir results; fi;
		Rscript src/quick_body_size.R data/all_body_size_parsed.dat results/final


clean:
	rm -f data/all_reverals.rev data/all_good_numbers.dat data/all_body_size.dat
	rm -f data/all_reverals_parsed.rev
	rm -f data/all_good_numbers_parsed.dat
	rm -f data/all_body_size_parsed.dat
	rm -f results/final_ha_plot.pdf
	rm -f results/final_length_plot.pdf
