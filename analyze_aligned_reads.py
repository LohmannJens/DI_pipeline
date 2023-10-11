'''
    Tests different classifers on different data sets. Also tests which
    combination of features is the best.
'''
import os
import argparse
import warnings

import pandas as pd

DATASET_STRAIN_DICT = dict({
    "Alnaji2019" : "Alnaji2019",
    "Alnaji2021": "PR8",
    "Pelz2021": "PR8",
    "Mendes2021": "WSN",
    "Wang2023": "PR8",
    "Lui2019": "Anhui",
    "Wang2018": "PR8",
    "Penn2022": "Turkey",
    "Kupke2020": "PR8"
})

SEGMENT_DICTS = dict({
    "PR8": dict({
        "AF389115.1": "PB2",
        "AF389116.1": "PB1",
        "AF389117.1": "PA",
        "AF389118.1": "HA",
        "AF389119.1": "NP",
        "AF389120.1": "NA",
        "AF389121.1": "M",
        "AF389122.1": "NS"
    }),
    "Alnaji2019": dict({
        "CY121687.1": "PB2",
        "CY121686.1": "PB1",
        "CY121685.1": "PA",
        "CY121680.1": "HA",
        "CY121683.1": "NP",
        "CY121682.1": "NA",
        "CY121681.1": "M",
        "CY121684.1": "NS",
        "CY147325.1": "PB2",
        "CY147324.1": "PB1",
        "CY147323.1": "PA",
        "CY147318.1": "HA",
        "CY147321.1": "NP",
        "CY147320.1": "NA",
        "CY147319.1": "M",
        "CY147322.1": "NS",
        "KJ609203.1": "PB2",
        "KJ609204.1": "PB1",
        "KJ609205.1": "PA",
        "KJ609206.1": "HA",
        "KJ609207.1": "NP",
        "KJ609208.1": "NA",
        "KJ609209.1": "M",
        "KJ609210.1": "NS",
        "CY115118.1": "PB2",
        "CY115117.1": "PB1",
        "CY115116.1": "PA",
        "CY115111.1": "HA",
        "CY115114.1": "NP",
        "CY115113.1": "NA",
        "CY115112.1": "M",
        "CY115115.1": "NS"
    }),
    "WSN": dict({
        "PB2": "PB2",
        "PB1": "PB1",
        "PA": "PA",
        "HA": "HA",
        "NP": "NP",
        "NA": "NA",
        "M": "M",
        "NS": "NS"
    }),
    "_WSN": dict({
        "CY034139.1": "PB2",
        "CY034138.1": "PB1",
        "CY034137.1": "PA",
        "CY034132.1": "HA",
        "CY034135.1": "NP",
        "CY034134.1": "NA",
        "CY034133.1": "M",
        "CY034136.1": "NS"
    }),
    "Anhui": dict({
        "439504|A/Anhui/1/2013|PB2": "PB2",
        "439508|A/Anhui/1/2013|PB1": "PB1",
        "439503|A/Anhui/1/2013|PA": "PA",
        "439507|A/Anhui/1/2013|HA": "HA",
        "439505|A/Anhui/1/2013|NP": "NP",
        "439509|A/Anhui/1/2013|NA": "NA",
        "439506|A/Anhui/1/2013|M": "M",
        "439510|A/Anhui/1/2013|NS": "NS"
    }),
    "Turkey": dict({
        "EF619975.1": "PB2",
        "EF619976.1": "PB1",
        "EF619979.1": "PA",
        "AF389118.1": "HA",
        "EF619977.1": "NP",
        "EF619973.1": "NA",
        "EF619978.1": "M",
        "EF619974.1": "NS"
    })
})


def analyse_mapped_reads(author, acc_num):
    '''
        Function to validate the generated models by comparing to artificially.
        :param df: data frame containing all data sets

        :return: None
    '''
    segment_dict = SEGMENT_DICTS[DATASET_STRAIN_DICT[author]]
    counter = dict()
    for segment in segment_dict.values():
        counter[segment] = 0

    n_lines = 0

    path = os.path.join("results", args.author, "virema")
    filename = args.sra_acc + "_unaligned_Single_Alignments.txt"
    file = os.path.join(path, filename)
    with open(file, "r") as f:
        for l in f.readlines():
            n_lines += 1
            for segment in segment_dict.keys():
                if segment in l:
                    counter[segment_dict[segment]] += 1
                    continue

    df_data = dict({
        "segment": counter.keys(),
        "counts": counter.values()
    })

    df = pd.DataFrame(df_data)

    out_file = acc_num + "_mapped_reads_per_segment.csv"
    out_path = os.path.join("results", args.author, "final", out_file)
    df.to_csv(out_path, index=False)


if __name__ == "__main__":
    warnings.simplefilter(action="ignore", category=FutureWarning)
    
    # argument parsing
    p = argparse.ArgumentParser(description="Analyse mapped reads")
    p.add_argument("--author", "-a", type=str, help="Name of author")
    p.add_argument("--sra_acc", "-s", type=str, help="SRA accession number")
    args = p.parse_args()

    analyse_mapped_reads(args.author, args.sra_acc)
