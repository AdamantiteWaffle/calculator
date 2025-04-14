#!/bin/bash

printf "Enter the type calculation to make:\nmn - mean\nmd - median\nmo - mode\nstdev - standard deviation\nsort\niqr - interquartile range\nThis calculator is cabable of exponents, but they must be specified as "e+0x," where x is the exponent.\nFor example, 6*10^1 is 6e+01. 6*10^2 is 6e+02.\n"
read datatype
	case $datatype in
		mn)
			echo "Enter data set, separated by commas with no spaces."
			read mean
			result=$(echo "$mean" | awk -vOFMT=%.10f -F, '{ sum = 0; for(i=1; i<=NF; i++) sum += $i; print sum/NF }';)
			echo "$result"
		;;
		md)
		echo "Enter data set, separated by commas with no spaces."
			read median
			sorted_numbers=($(echo "$median" | tr "," "\n" | sort -n))
			count=${#sorted_numbers[@]}
			median_index=$((count / 2))
			if ((count % 2 == 0)); then
			    median_value=$(((sorted_numbers[median_index - 1] + sorted_numbers[median_index]) / 2))
			else
			    median_value=${sorted_numbers[median_index]}
			fi
			echo "$median_value"
		;;
		mo)
			echo "Enter data set, separated by commas with no spaces."
			read mode
			echo "$mode" | tr "," "\n" > mode2
			sort -n mode2 | uniq --count | sort -rn | head -n 1 > mode3
			cat mode3
		;;
		stdev)
			echo "Choose whether to calculate a sample or a population.\n"
			read response
				case $response in
					sample)
						echo "Enter data set, separated by commas with no spaces. \n"
						read input
						read -ra data_set <<< $(echo "$input" | tr "," " ")
						mean=$(echo "${data_set[*]}" | awk '{ sum = 0; for(i=1; i<=NF; i++) sum += $i; print sum/NF }';)
						echo "The mean is $mean"
						results=($(for element in "${data_set[@]}"; do
							echo "$element" | awk -v mean="$mean" '{
								for (i = 1; i <= NF; i++) {
									print $i - mean;
								}
							}'
						done))
						printf "%s\n" "${results[@]}"
						printf "\n The above results are the mean subtracted from each data point\n"
						squares=($(for elements in "${results[@]}"; do
							echo "$elements" | awk '{print $elements*$elements; }'
						done))
						printf "%s\n" "${squares[@]}"
						printf "\n The above results are the prior elements squared\n"
						average=($(echo "${squares[@]}" | awk -vOFMT=%.10f '{
							        sum = 0;
							        for (i = 1; i <= NF; i++) {
							            sum += $i;
							        }
							        print sum / (NF - 1);
							    }'))
						printf "%s\n" "${average[@]}"
						printf "\n The above result is the average of the prior results.\n"
						stdev=$(bc <<< "scale=0; sqrt(${average[@]})")
						printf "%s\n" "$stdev"
						printf "\n The above result is the standard deviation.\n"
					;;
					population)
						echo "Enter data set, separated by commas with no spaces. \n"
						read input
						read -ra data_set <<< $(echo "$input" | tr "," " ")
						mean=$(echo "${data_set[*]}" | awk '{ sum = 0; for(i=1; i<=NF; i++) sum += $i; print sum/NF }';)
						echo "The mean is $mean"
						results=($(for element in "${data_set[@]}"; do
							echo "$element" | awk -v mean="$mean" '{
								for (i = 1; i <= NF; i++) {
									print $i - mean;
								}
							}'
						done))
						printf "%s\n" "${results[@]}"
						printf "\n The above results are the mean subtracted from each data point\n"
						squares=($(for elements in "${results[@]}"; do
							echo "$elements" | awk '{print $elements*$elements; }'
						done))
						printf "%s\n" "${squares[@]}"
						printf "\n The above results are the prior elements squared\n"
						average=($(echo "${squares[@]}" | awk -vOFMT=%.10f '{
							        sum = 0;
							        for (i = 1; i <= NF; i++) {
							            sum += $i;
							        }
							        print sum / NF;
							    }'))
						printf "%s\n" "${average[@]}"
						printf "\n The above result is the average of the prior results.\n"
						stdev=$(bc <<< "scale=0; sqrt(${average[@]})")
						printf "%s\n" "$stdev"
						printf "\n The above result is the standard deviation.\n"
					;;
				esac
		;;
		"sort")
			echo "Choose how to sort: [L]argest to smallest [S]mallest to largest"
			read input
			case $input in
				L)
					read input2
					echo "$input2" | tr "," "\n" | sort -nr > sorted
					cat sorted
				;;
				S)
					read input2
					echo "$input2" | tr "," "\n" | sort -n > sorted
					cat sorted
				;;
			esac
		;;
		"iqr")
			 echo "Input data set, separated by commas with no spaces."
				read input
				readarray -t array1 <<< "$(echo "$input" | tr ',' '\n' | sort -n)"
				read -ra dataset <<< "$(printf '%s ' "${array1[@]}")"
				echo "${dataset[@]}"
				if [ $((${#dataset[@]} % 2)) -eq 0 ];
					then
						arrl=${#dataset[@]}
						mid=$((arrl / 2))
						h1=("${dataset[@]:0:mid}")
						h2=("${dataset[@]:mid}")
						echo "First half: ${h1[@]}"
						echo "Second half: ${h2[@]}"
						count1=${#h1[@]}
						count2=${#h2[@]}
						mdi1=$((count1 /2))
						mdi2=$((count2 /2))
						if ((count1 % 2 == 0)); then
									    mdh1=$(((h1[mdi1 - 1] + count1[mdi1]) / 2))
									else
									    mdh1=${h1[mdi1]}
									fi
						if ((count2 % 2 == 0)); then
									    mdh2=$(((h2[mdi2 - 1] + count2[mdi2]) / 2))
									else
									    mdh2=${h2[mdi2]}
									fi
						echo "The median of the first half is $mdh1"
						echo "The median of the second half is $mdh2"
						iqr=$(expr $mdh2 - $mdh1)
						echo "The interquartile range is $iqr"
					else
						arrl=${#dataset[@]}
						mid=$(((arrl + 1) / 2))
						h1=("${dataset[@]:0:$(expr $mid - 1)}")
						h2=("${dataset[@]:mid}")
						echo "First half: ${h1[@]}"
						echo "Second half: ${h2[@]}"
						count1=${#h1[@]}
						count2=${#h2[@]}
						mdi1=$((count1 /2))
						mdi2=$((count2 /2))
						if ((count1 % 2 == 0)); then
						    mdh1=$(((h1[mdi1 - 1] + count1[mdi1]) / 2))
						else
						    mdh1=${h1[mdi1]}
						fi
						if ((count2 % 2 == 0)); then
						    mdh2=$(((h2[mdi2 - 1] + count2[mdi2]) / 2))
						else
						    mdh2=${h2[mdi2]}
						fi
						echo "The median of the first half is $mdh1"
						echo "The median of the second half is $mdh2"
						iqr=$(expr $mdh2 - $mdh1)
						echo "The interquartile range is $iqr"
				fi
		;;
	esac
