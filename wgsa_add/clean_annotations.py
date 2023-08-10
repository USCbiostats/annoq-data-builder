import re

def remove_duplicates(input_string):
    parts = input_string.split('|')
    seen = set()
    return '|'.join(part.strip() for part in parts if part.strip() not in seen and not seen.add(part.strip()))

def remove_patterns(input_string):
    pattern = r'\.(?:\|\.)*'
    return re.sub(pattern, '', input_string)

def remove_specific_string(input_string):
    return re.sub(r'NONE:NONE\(dist=NONE\),?', '', input_string)
  
def remove_dots(input_string):
    return re.sub(r'\s*\.\s*', '', input_string)

def clean_cell(cell): 
    if not cell:
       return ''
    # Remove specific string NONE:NONE(dist=NONE),
    cell = remove_specific_string(cell)
    # Remove duplicates upstream|downstream|downstream => upstream|downstream
    cell = remove_duplicates(cell)
    # Remove patterns .|.|.| but it is covered by removal of duplicates, so we just remove "."
    cell = remove_dots(cell)
  
    return cell

def clean_line(line):    
    cells = line.strip().split('\t')
    cleaned_cells = [clean_cell(cell) for cell in cells]
    cleaned_line = '\t'.join(cleaned_cells)
   
    return cleaned_line
