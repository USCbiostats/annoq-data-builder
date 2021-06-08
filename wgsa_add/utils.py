
import json


hgnc_file = './../../annoq-data/wgsa_add/hgnc.txt'


def load_hgnc_ensg_to_hgnc_table(filepath=hgnc_file, debug=False):
    f = open(filepath, encoding="utf-8")
    f.readline()
    mapping = {}
    for i in f:
        line = i.rstrip().split('\t')
        try:
            hgnc_id, ensg = line[0], line[9]
        except:
            if debug:
                print('error in line:')
                print(i)
                print(len(line))
            continue
        if ensg == '':
            continue
        if mapping.get(ensg):
            mapping[ensg].append(hgnc_id)
        else:
            mapping[ensg] = [hgnc_id]
    return mapping


def combine_record(r_list, seq='|'):
    first = r_list[0][:]
    for i in r_list[1:]:
        for idx in range(len(first)):
            first[idx] += seq + i[idx]
    return first


def combine_panther_record(ids, panther_data, sep='|'):
    panther_record_length = len(panther_data['cols']) - 1
    ids = [i for i in ids if i in panther_data['data']]
    if not ids:
        return ['.' for i in range(panther_record_length)]
    res = [[] for i in range(panther_record_length)]
    for pid in ids:
        anno = panther_data['data'][pid]
        for idx in range(0, panther_record_length, 2):
            cur_data = anno[idx].split(sep)
            follow_data = anno[idx + 1].split(sep)
            for i in range(len(cur_data)):
                if cur_data[i] == '.' and follow_data[i] == '.':
                    continue
                if not cur_data[i] in res[idx]:
                    res[idx].append(cur_data[i])
                    res[idx + 1].append(follow_data[i])
    for idx in range(len(res)):
        if not res[idx]:
            res[idx] = '.'
    return list(map(lambda x: sep.join(x), res))


def parse_tab_anno_record(r):
    (chrom, pos) = r.split("\t")[:2]
    return chrom, int(pos)


def add_record(r, add_info, sep='\t'):
    return r.rstrip() + sep + sep.join(add_info) + '\n'


def load_hgnc_ensg_to_hgnc_table(filepath=hgnc_file, debug=False):
    f = open(filepath, encoding="utf-8")
    f.readline()
    mapping = {}
    for i in f:
        line = i.rstrip().split('\t')
        try:
            hgnc_id, ensg = line[0], line[9]
        except:
            if debug:
                print('error in line:')
                print(i)
                print(len(line))
            continue
        if ensg == '':
            continue
        if mapping.get(ensg):
            mapping[ensg].append(hgnc_id)
        else:
            mapping[ensg] = [hgnc_id]
    return mapping


ensg_to_hgnc_table = load_hgnc_ensg_to_hgnc_table()
# ensg_to_hgnc_table


def convert_ensg_hgnc(ensg):
    hgncs = ensg_to_hgnc_table.get(ensg)
    if not hgncs:
        return ''
    return hgncs[0]


def load_hgnc_refseq_to_hgnc_table(filepath=hgnc_file, debug=False):
    f = open(filepath, encoding="utf-8")
    f.readline()
    mapping = {}
    for i in f:
        line = i.rstrip().split('\t')
        try:
            hgnc_id, refseq = line[0], line[8]
        except:
            if debug:
                print('error in line:')
                print(i)
                print(len(line))
            continue
        if refseq == '':
            continue
        if mapping.get(refseq):
            mapping[refseq].append(hgnc_id)
        else:
            mapping[refseq] = [hgnc_id]
    return mapping


refseq_to_hgnc_table = load_hgnc_refseq_to_hgnc_table()
# ensg_to_hgnc_table


def convert_refseq_hgnc(refseq):
    hgncs = refseq_to_hgnc_table.get(refseq)
    if not hgncs:
        return ''
    return hgncs[0]


def transcript_filter(name):
    if not '.' in name:
        return name
    return name[:name.find(".")]


convert_tools = {'ensembl_Gene_ID': convert_ensg_hgnc,
                 'refseq_Transcript_ID': lambda x: convert_refseq_hgnc(transcript_filter(x))}


def load_json(filepath):
    with open(filepath, encoding='utf-8') as f:
        return json.load(f)
