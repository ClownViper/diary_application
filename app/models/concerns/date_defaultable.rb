# date カラムのデフォルト値を今日に設定する共通ロジック
# Diary・HealthLog・Expense・Schedule など date を持つモデルで include して使う
module DateDefaultable
  extend ActiveSupport::Concern

  included do
    after_initialize do
      self.date ||= Date.current
    end
  end
end
