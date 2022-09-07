import requests, zipfile, io, os

zenodo_repo = 'https://zenodo.org/record/7058399/files/'
studies = [] # empty or specify studies to download. exmaple: ICB_Braun, ICB_Gide...
dir = '~/Data/TSV'

filenames = []
# if no studies are specified, get available data object names from ORCESTRA
if(len(studies) == 0):
    response = requests.get('https://www.orcestra.ca/api/clinical_icb/canonical')
    icb_objects = response.json()
    filenames = map(lambda obj: obj['name'] + '.zip', icb_objects)
else:
    filenames = map(lambda study: study + '.zip', studies)

# download zip files all specified (or all) studies
filenames = list(filenames)
for filename in filenames:
    os.mkdir(os.path.join(dir, str(filename).replace('.zip', '')))
    r = requests.get(zenodo_repo + filename + '?=download=1')
    z = zipfile.ZipFile(io.BytesIO(r.content))
    z.extractall(os.path.join(dir, str(filename).replace('.zip', '')))
