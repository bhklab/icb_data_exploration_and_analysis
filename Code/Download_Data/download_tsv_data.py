import requests
import zipfile
import io
import os

zenodo_repo = 'https://zenodo.org/record/7199344/files/'
# empty or specify studies to download. exmaple: ICB_Braun, ICB_Gide...
studies = []

# Download datasets into local_data directory at the root of the repository directory.
dir = '../../.local_data'
if not os.path.exists(dir):
    os.makedirs(dir)

filenames = []
# if no studies are specified, get available data object names from ORCESTRA
if (len(studies) == 0):
    response = requests.get(
        'https://www.orcestra.ca/api/clinical_icb/canonical')
    icb_objects = response.json()
    filenames = map(lambda obj: obj['name'] + '.zip', icb_objects)
    filenames = list(filenames) + ["ICB_Fumet1.zip", "ICB_Fumet2.zip"]
else:
    filenames = list(map(lambda study: study + '.zip', studies))

# download zip files all specified (or all) studies
for filename in filenames:
    os.mkdir(os.path.join(dir, str(filename).replace('.zip', '')))
    r = requests.get(zenodo_repo + filename + '?=download=1')
    z = zipfile.ZipFile(io.BytesIO(r.content))
    z.extractall(os.path.join(dir, str(filename).replace('.zip', '')))
