#!/bin/bash

printf "Enter the type calculation to make:\nmn - mean\nmd - median\nmo - mode\nstdev - standard deviation\nsort\niqr - interquartile range\nz-score\nrange\nThis calculator is cabable of exponents, but they must be specified as "e+0x," where x is the exponent.\nFor example, 6*10^1 is 6e+01. 6*10^2 is 6e+02.\n"
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
			mode2=$(echo "$mode" | tr "," "\n")
			mode3=$(echo "$mode2"| sort -n| uniq --count | sort -rn | head -n 1)
			echo "$mode3"
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
		"plot")
			echo "Enter X values, separated by commas with no spaces."
			read input
			readarray -t array1 <<< "$(echo "$input" | tr ',' '\n')"
			read -ra dataset <<< "$(printf '%s ' "${array1[@]}")"
			echo "Entery Y values, separated by commas with no spaces."
			read input2
			readarray -t array2 <<< "$(echo "$input1" | tr ',' '\n')"
			read -ra dataset1 <<< "$(printf '%s ' "${array2[@]}")"
			printf "%s\n" "$array1[@]} ${array2[@]}" | gnuplot -p -e 'set term dumb; plot "<cat" w l'
			
		;;
		"z-score")
			echo "Enter mean of data set"
			read mean
			echo "Enter standard deviation"
			read stdev
			p1stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean + stdev; print result; }')
			n1stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean - stdev; print result; }')
			echo "68.2% of the data lies between $n1stdev and $p1stdev"
			p2stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean + (stdev * 2); print result; }')
			n2stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean - (stdev * 2); print result; }')
			echo "95.4% of the data lies between $n2stdev and $p2stdev"
			p3stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean + (stdev * 3); print result; }')
			n3stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean - (stdev * 3); print result; }')
			echo "99.6% of the data lies between $n3stdev and $p3stdev"
			p4stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean + (stdev * 4); print result; }')
			n4stdev=$(awk -vOFMT=%.5f -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = mean - (stdev * 4); print result; }')
			echo "99.8% of the data lies between $n4stdev and $p4stdev"
			echo "Enter a data point to calculate the z-score"
			read point
			zscore=$(awk -vOFMT=%.5f -v point="$point" -v mean="$mean" -v stdev="$stdev" 'BEGIN { result = ((point - mean) / stdev); print result; }')
			echo "The z-score is $zscore"
			tzscore=$(printf "%.1f" "$zscore")
			IFS=';' read -ra arr <<< "$(curl -s --retry 5 'https://ztable.io/static/dl/ztable.csv' | grep "^$tzscore")"
			unset IFS
			echo "${arr[@]}"
			zindex=$(printf "%.2f" "$zscore" | grep -Eo '[0-9]' | tail -1)
			echo "$zindex"
			unset arr[0]
			echo ${arr[@]}
			echo "${arr[0]}"
			output=$(("$zindex" + 1))
			output2=$(awk -v thing="${arr[$output]}" 'BEGIN { result = thing * 100; print result; }')
			echo "$output2% of the data lies at or below $point"
			greater=$(awk -v output2="$output2" 'BEGIN { result = (100 - output2); print result; }')
			echo "$greater% of the data lies at or above $point"
		;;
		"range")
			echo "Enter data set, separated by commas"
			read input
			readarray -t dataset <<< "$(echo "$input" | tr "," "\n" | sort -n)"
			echo "${dataset[@]}"
			range=$(("${dataset[-1]}" - "${dataset[1]}"))
			echo "$range"
		;;
	esac
