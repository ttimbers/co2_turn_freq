all: data/all_reverals_parsed.rev data/all_good_numbers_parsed.dat data/all_all_body_size_parsed.dat

data/all_reverals.rev data/all_good_numbers.dat data/all_body_size.dat: src/run_chore.sh
	bash src/run_chore.sh data

data/all_reverals_parsed.rev: src/parse_column.R data/all_reverals.rev
	Rscript src/parse_column.R data/all_reverals.rev data/all_reverals_parsed.rev object_id t_reversal reversal_distance reversal_duration

data/all_good_numbers_parsed.dat: src/parse_column.R data/all_good_numbers.dat
	Rscript src/parse_column.R data/all_good_numbers.dat data/all_good_numbers_parsed.dat time good_number

data/all_all_body_size_parsed.dat: src/parse_column.R data/all_body_size.dat
		Rscript src/parse_column.R data/all_body_size.dat data/all_all_body_size_parsed.dat time area midline morphwidth

clean:
	rm -f data/all_reverals.rev data/all_good_numbers.dat data/all_body_size.dat
	rm -f data/all_reverals_parsed.rev
	rm -f data/all_good_numbers_parsed.dat
	rm -f data/all_all_body_size_parsed.dat
