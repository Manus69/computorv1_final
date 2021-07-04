NAME = computor
compiler = dmd
main = main.d
source_folder = ./src
# flags = -O
flags = -g -wi -I=$(source_folder)
source_names = complex.d my_exception.d parser.d print.d solvers.d support.d \
		main.d numeric_solvers.d polynomial.d recognizers.d sqrt.d tokens.d
objects_folder = ./objects
# extension = .o
extension = .obj
objects = $(addprefix $(objects_folder)/,$(source_names:.d=$(extension)))
sources = $(addprefix $(source_folder)/,$(source_names))

all: $(objects) $(NAME)

test:
	echo $(source_names)
	echo $(sources)
	echo $(objects_folder)
	echo $(objects)


$(NAME) : $(objects)
	$(compiler) $(flags) $(objects) -of=$(NAME)

$(objects_folder)/%$(extension) : $(source_folder)/%.d
	$(compiler) $(flags) -c $< -of=$@

clean:
	rm -f $(objects)

fclean:
	make clean
	rm -f $(NAME)

re:
	make fclean
	make all