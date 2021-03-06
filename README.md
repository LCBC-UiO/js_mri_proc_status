# MRI processing status

This little application should enable users to keep track of and edit the status of processing for the MRI data.

## Running a localhost server of the application

To prepare the application to run, you will need to download all the necessary components.
```sh
make download
```

And then build the necessary tools.
```sh
make build
```

Then run the instance with

```sh
make run_webui
```

The web application will by default be running on port `6565`

## Preparing to move into TSD
To move into TSD, its best to start from a clean folder and then prepare for offline work.

```sh
make prepare_offline
```

The folder will reset all files, download what is needed, and clear away all unecessary files.
The entire folder will be zipped for easy move to TSD, and be located in the folder above the working directory, with the basename of the working directory as the zip file name.
Usually this will ne `js_nettfix.zip`, unless the folder has been renamed on git clone.

Upload the zip file into TSD, and make a tuls service to run the webapplication.

```sh
make build
make run_webui
```
