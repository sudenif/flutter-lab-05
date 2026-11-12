/// Этот репозиторий содержит только лабораторную работу 5.
enum LabStage { lab5 }

extension LabStageFeatures on LabStage {
  bool get usesApiList => true;
  bool get usesApiDetails => true;
  bool get hasDetails => true;
}
