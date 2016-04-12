#---------------------------------------------------------------------
# This file extracts MeSH(medical Subject Headings) Descriptors data
#---------------------------------------------------------------------
import xml.etree.ElementTree as ET

def parse_XML():
    tree = ET.parse('../data/mesh/desc2016.xml')
    print 'tree extracted'
    root = tree.getroot()
    print 'root extracted'
    print root, root.tag, root.attrib
    # count = 0
    # count_q = 0
    # for qrs_child in root:
    #     count += 1
    #     #print child.tag, child.attrib
    #     for qr_child in qrs_child:
    #         count_q += 1
    # print count, count_q
    #QualifierRecordElem = tree.find('QualifierRecord')
    #print QualifierRecordElem.text        # element text
    #print QualifierRecordElem.get('') # attribute

    #for iterating recursively over a specified child name
    # for QualifierUI in root.iter('QualifierUI'):
    #     print QualifierUI.text

    #preparing term - ConceptUI, ConceptName mapping
    count = 0
    desc_concepts_mapping = {}
    #findall - searches for all direct children with the name
    for DescriptorRecord in root.findall('DescriptorRecord'):
        count += 1
        print 'processing DescriptorRecord -- ', count
        str = DescriptorRecord.find('DescriptorName').find('String').text.encode('utf8')
        #print str

        if str not in desc_concepts_mapping.keys():
            desc_concepts_mapping[str] = []

        for Concept in DescriptorRecord.find('ConceptList').findall('Concept'):
            conceptUI = Concept.find('ConceptUI').text.encode('utf8')
            conceptName = Concept.find('ConceptName').find('String').text.encode('utf8')
            desc_concepts_mapping[str].append((conceptUI,conceptName))


    #print('desc_concepts_mapping :: ',desc_concepts_mapping)
    return desc_concepts_mapping


def extract_synonym_words(desc_concepts_mapping):
     #searching for words having same ConceptUI
    conceptUI_dict = {}
    test = []
    for term,concept_lst in desc_concepts_mapping.iteritems():
        for concept_tup in concept_lst:
            concept_ui = concept_tup[0]
            test.append(concept_ui)
            concept_name = concept_tup[1]
            if concept_ui not in conceptUI_dict.keys():
                conceptUI_dict[concept_ui] = [term]
            else:
                print 'conceptUI repeated'
                conceptUI_dict[concept_ui].append(term)

    #print 'conceptUI_dict ::', conceptUI_dict
    print 'test concept UIs ::',len(test), len(set(test))

    #writing synonyms in text file
    f = open('descData/desc_synonyms.txt','w+')
    for concept_ui,syn_lst in conceptUI_dict.iteritems():
        f.write(concept_ui+'\n')
        str = ''
        count = 0
        for term in syn_lst:
            count += 1
            if count == 1:
                str = term
            else:
                str = str + ',' + term

        f.write(str+'\n')

    #return conceptUI_dict


def extract_similar_words(desc_concepts_mapping):
    f = open('descData/desc_similar_concepts.txt','w+')
    for term,concept_lst in desc_concepts_mapping.iteritems():
        str = term
        for concept_tup in concept_lst:
            #concept_ui = concept_tup[0]
            concept_name = concept_tup[1]
            str = str + ',' + concept_name

        f.write(str)
        f.write('\n')



#testing lag
desc_concepts_mapping = parse_XML()
extract_similar_words(desc_concepts_mapping)
extract_synonym_words(desc_concepts_mapping)
